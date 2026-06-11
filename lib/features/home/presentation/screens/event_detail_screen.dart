import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/event_model.dart';
import 'event_register_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final UserModel? currentUser;

  const EventDetailScreen({super.key, required this.event, this.currentUser});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  static const _likedEventsKey = 'liked_event_ids';
  static const _dislikedEventsKey = 'disliked_event_ids';
  static const _registeredEventsKey = 'registered_event_ids';

  late int _likes;
  late int _dislikes;
  bool _likedByUser = false;
  bool _dislikedByUser = false;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.event.likes;
    _dislikes = widget.event.dislikes;
    _loadInteractionState();
  }

  void _onLike() {
    setState(() {
      if (_likedByUser) {
        _likes--;
        _likedByUser = false;
      } else {
        _likes++;
        _likedByUser = true;
        if (_dislikedByUser) {
          _dislikes--;
          _dislikedByUser = false;
        }
      }
    });
    unawaited(_saveReactionState());
  }

  void _onDislike() {
    setState(() {
      if (_dislikedByUser) {
        _dislikes--;
        _dislikedByUser = false;
      } else {
        _dislikes++;
        _dislikedByUser = true;
        if (_likedByUser) {
          _likes--;
          _likedByUser = false;
        }
      }
    });
    unawaited(_saveReactionState());
  }

  Future<void> _loadInteractionState() async {
    final prefs = await SharedPreferences.getInstance();
    final likedEvents = prefs.getStringList(_likedEventsKey) ?? const [];
    final dislikedEvents = prefs.getStringList(_dislikedEventsKey) ?? const [];
    final registeredEvents =
        prefs.getStringList(_registeredEventsKey) ?? const [];

    final liked = likedEvents.contains(widget.event.id);
    final disliked = !liked && dislikedEvents.contains(widget.event.id);

    if (!mounted) return;
    setState(() {
      _likedByUser = liked;
      _dislikedByUser = disliked;
      _registered = registeredEvents.contains(widget.event.id);
      _likes = widget.event.likes + (liked ? 1 : 0);
      _dislikes = widget.event.dislikes + (disliked ? 1 : 0);
    });
  }

  Future<void> _saveReactionState() async {
    final prefs = await SharedPreferences.getInstance();
    final likedEvents = (prefs.getStringList(_likedEventsKey) ?? const [])
        .toSet();
    final dislikedEvents = (prefs.getStringList(_dislikedEventsKey) ?? const [])
        .toSet();

    if (_likedByUser) {
      likedEvents.add(widget.event.id);
    } else {
      likedEvents.remove(widget.event.id);
    }

    if (_dislikedByUser) {
      dislikedEvents.add(widget.event.id);
    } else {
      dislikedEvents.remove(widget.event.id);
    }

    await prefs.setStringList(_likedEventsKey, likedEvents.toList());
    await prefs.setStringList(_dislikedEventsKey, dislikedEvents.toList());
  }

  Future<void> _openRegistration() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventRegisterScreen(
          event: widget.event,
          currentUser: widget.currentUser,
        ),
      ),
    );

    if (!mounted || registered != true) return;
    setState(() => _registered = true);
    await _saveRegistrationState();
  }

  Future<void> _saveRegistrationState() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredEvents =
        (prefs.getStringList(_registeredEventsKey) ?? const []).toSet();
    registeredEvents.add(widget.event.id);
    await prefs.setStringList(_registeredEventsKey, registeredEvents.toList());
  }

  Future<void> _shareToWhatsApp() async {
    final event = widget.event;
    final dateStr = DateFormat('EEE, MMM d yyyy · h:mm a').format(event.date);
    final message =
        '🎉 *${event.title}*\n $dateStr\n ${event.location}\nOrganized by: ${event.organizer}\n\nCheck it out on ${AppConstants.appName}!';
    final uri = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed on this device.'),
          ),
        );
      }
    }
  }

  Future<void> _contactOrganizer() async {
    final uri = Uri(
      scheme: 'mailto',
      path: widget.event.organizerEmail,
      query:
          'subject=Question about ${Uri.encodeComponent(widget.event.title)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(event.date);
    final timeStr = DateFormat('h:mm a').format(event.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _EventSliverAppBar(event: event),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        label: event.isPaid
                            ? 'Paid - RWF ${event.price?.toInt()}'
                            : 'Free',
                        color: event.isPaid
                            ? AppColors.alert
                            : AppColors.success,
                      ),
                      if (event.isOnCampus)
                        const _Chip(
                          label: 'On Campus',
                          color: AppColors.secondaryBlue,
                        ),
                      if (event.hasFood)
                        const _Chip(
                          label: 'Food Provided',
                          color: Color(0xFF7C5C00),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 20),

                  // Info cards
                  _InfoCard(
                    children: [
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Organizer',
                        value: event.organizer,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: dateStr,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: timeStr,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: event.location,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About this Event',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reactions
                  _ReactionRow(
                    likes: _likes,
                    dislikes: _dislikes,
                    comments: event.comments,
                    likedByUser: _likedByUser,
                    dislikedByUser: _dislikedByUser,
                    onLike: _onLike,
                    onDislike: _onDislike,
                  ),
                  const SizedBox(height: 24),

                  // Contact organizer
                  OutlinedButton.icon(
                    onPressed: _contactOrganizer,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Contact Organizer'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Share to WhatsApp
                  OutlinedButton.icon(
                    onPressed: _shareToWhatsApp,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share to WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Register button
                  ElevatedButton.icon(
                    onPressed: _registered ? null : _openRegistration,
                    icon: Icon(
                      _registered
                          ? Icons.check_circle_outline
                          : Icons.how_to_reg_outlined,
                    ),
                    label: Text(
                      _registered ? 'Registered' : 'Register for This Event',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver App Bar ────────────────────────────────────────────────────────────

class _EventSliverAppBar extends StatelessWidget {
  final Event event;
  const _EventSliverAppBar({required this.event});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: event.headerColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: event.headerColor,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.event,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReactionRow extends StatelessWidget {
  final int likes;
  final int dislikes;
  final int comments;
  final bool likedByUser;
  final bool dislikedByUser;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _ReactionRow({
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.likedByUser,
    required this.dislikedByUser,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ReactionButton(
            icon: likedByUser ? Icons.thumb_up : Icons.thumb_up_outlined,
            count: likes,
            active: likedByUser,
            activeColor: AppColors.success,
            onTap: onLike,
          ),
          Container(width: 1, height: 28, color: AppColors.border),
          _ReactionButton(
            icon: dislikedByUser ? Icons.thumb_down : Icons.thumb_down_outlined,
            count: dislikes,
            active: dislikedByUser,
            activeColor: AppColors.alert,
            onTap: onDislike,
          ),
          Container(width: 1, height: 28, color: AppColors.border),
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                '$comments comments',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
