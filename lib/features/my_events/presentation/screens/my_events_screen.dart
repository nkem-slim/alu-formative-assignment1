import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  static const _pendingEventKey = 'my_events_pending_event';
  static const _defaultPendingEvent = _SubmittedEventDraft(
    title: 'Fintech Hackathon',
    date: 'Jul 5 - 9:00 AM',
    location: 'Innovation Lab',
    footer: 'Awaiting admin review',
  );

  late TabController _tabController;
  _SubmittedEventDraft _pendingEvent = _defaultPendingEvent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPendingEvent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MyEventsHeader(),
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              dividerColor: AppColors.border,
              tabs: const [
                Tab(text: 'Approved'),
                Tab(text: 'Pending'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApprovedTab(context),
                _buildPendingTab(),
                _buildCancelledTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _MyEventCard(
          title: 'ALU Career Fair 2026',
          status: 'Approved',
          statusColor: AppColors.success,
          statusBg: AppColors.success,
          date: 'Jun 18 - 10:00 AM',
          location: 'Main Hall',
          footer: '47 attendees',
          footerIcon: Icons.groups_outlined,
          actionLabel: 'View attendees',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendeeDetailScreen(
                title: 'ALU Career Fair 2026',
                date: 'Jun 18, 2026 - 10:00 AM - 5:00 PM',
                location: 'Main Hall, Kigali Campus',
                attendeeCount: 47,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _MyEventCard(
          title: 'Tech Talk: AI in Africa',
          status: 'Approved',
          statusColor: AppColors.success,
          statusBg: AppColors.success,
          date: 'Jun 25 - 2:00 PM',
          location: 'Room B3',
          footer: '23 attendees',
          footerIcon: Icons.groups_outlined,
          actionLabel: 'View attendees',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendeeDetailScreen(
                title: 'Tech Talk: AI in Africa',
                date: 'Jun 25, 2026 - 2:00 PM - 4:00 PM',
                location: 'Room B3, Kigali Campus',
                attendeeCount: 23,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _MyEventCard(
          title: _pendingEvent.title,
          status: 'Pending',
          statusColor: const Color(0xFFB8860B),
          statusBg: const Color(0xFFB8860B),
          date: _pendingEvent.date,
          location: _pendingEvent.location,
          footer: _pendingEvent.footer,
          footerIcon: Icons.pending_actions_outlined,
          actionLabel: 'Edit',
          actionOutline: true,
          onAction: _editPendingEvent,
        ),
      ],
    );
  }

  Future<void> _editPendingEvent() async {
    final updated = await Navigator.push<_SubmittedEventDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => _EditSubmittedEventScreen(event: _pendingEvent),
      ),
    );

    if (!mounted || updated == null) return;
    setState(() => _pendingEvent = updated);
    await _savePendingEvent(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event updated and sent back for admin review.'),
      ),
    );
  }

  Future<void> _loadPendingEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_pendingEventKey);
    if (encoded == null) return;

    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final event = _SubmittedEventDraft.fromJson(decoded);
      if (!mounted) return;
      setState(() => _pendingEvent = event);
    } catch (_) {
      await prefs.remove(_pendingEventKey);
    }
  }

  Future<void> _savePendingEvent(_SubmittedEventDraft event) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEventKey, jsonEncode(event.toJson()));
  }

  Widget _buildCancelledTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Opacity(
          opacity: 0.7,
          child: _MyEventCard(
            title: 'Study Group: Data Structures',
            status: 'Cancelled',
            statusColor: AppColors.alert,
            statusBg: AppColors.alert,
            date: 'May 30 - 4:00 PM',
            location: 'Library',
            footer: 'Venue unavailable',
            footerIcon: Icons.block_outlined,
            actionLabel: '',
            onAction: null,
          ),
        ),
      ],
    );
  }
}

class _MyEventsHeader extends StatelessWidget {
  const _MyEventsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      color: AppColors.surface,
      child: Text('My Events', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _MyEventCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String date;
  final String location;
  final String footer;
  final IconData footerIcon;
  final String actionLabel;
  final bool actionOutline;
  final VoidCallback? onAction;

  const _MyEventCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.date,
    required this.location,
    required this.footer,
    required this.footerIcon,
    required this.actionLabel,
    this.actionOutline = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusPill(
                              label: status,
                              color: statusColor,
                              backgroundColor: statusBg,
                            ),
                            if (actionLabel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _ActionPill(
                                label: actionLabel,
                                outline: actionOutline,
                              ),
                            ],
                            const Spacer(),
                            if (onAction != null)
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        _MyEventMetaRow(
                          icon: Icons.calendar_today_outlined,
                          text: date,
                        ),
                        const SizedBox(height: 6),
                        _MyEventMetaRow(
                          icon: Icons.location_on_outlined,
                          text: location,
                        ),
                        const SizedBox(height: 6),
                        _MyEventMetaRow(icon: footerIcon, text: footer),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final bool outline;

  const _ActionPill({required this.label, required this.outline});

  @override
  Widget build(BuildContext context) {
    final foregroundColor = outline ? AppColors.textMuted : AppColors.primary;
    final backgroundColor = outline
        ? AppColors.background
        : AppColors.accent.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: outline ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MyEventMetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MyEventMetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _SubmittedEventDraft {
  final String title;
  final String date;
  final String location;
  final String footer;

  const _SubmittedEventDraft({
    required this.title,
    required this.date,
    required this.location,
    required this.footer,
  });

  factory _SubmittedEventDraft.fromJson(Map<String, dynamic> json) {
    return _SubmittedEventDraft(
      title: json['title'] as String? ?? 'Untitled Event',
      date: json['date'] as String? ?? 'Date pending',
      location: json['location'] as String? ?? 'Location pending',
      footer: json['footer'] as String? ?? 'Awaiting admin review',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'footer': footer,
    };
  }
}

class _EditSubmittedEventScreen extends StatefulWidget {
  final _SubmittedEventDraft event;

  const _EditSubmittedEventScreen({required this.event});

  @override
  State<_EditSubmittedEventScreen> createState() =>
      _EditSubmittedEventScreenState();
}

class _EditSubmittedEventScreenState extends State<_EditSubmittedEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _dateController = TextEditingController(text: widget.event.date);
    _locationController = TextEditingController(text: widget.event.location);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _SubmittedEventDraft(
        title: _titleController.text.trim(),
        date: _dateController.text.trim(),
        location: _locationController.text.trim(),
        footer: 'Awaiting admin review',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFB8860B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFB8860B).withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.pending_actions_outlined,
                    color: Color(0xFFB8860B),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saving changes keeps this event pending for admin approval.',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the event title'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date and Time'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the date and time'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the location'
                  : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save and Resubmit'),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendeeDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final int attendeeCount;

  const AttendeeDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.attendeeCount,
  });

  static const _attendees = [
    {'initials': 'AK', 'name': 'Amara Kone', 'email': 'a.kone@alustudent.com'},
    {
      'initials': 'BM',
      'name': 'Beatrice Mutesi',
      'email': 'b.mutesi@alustudent.com',
    },
    {
      'initials': 'CJ',
      'name': 'Claude Jabari',
      'email': 'c.jabari@alustudent.com',
    },
  ];

  Future<void> _sendReminder(BuildContext context) async {
    final emails = _attendees.map((attendee) => attendee['email']!).join(',');
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'bcc': emails,
        'subject': 'Reminder: $title',
        'body':
            'Hi,\n\nThis is a reminder for $title.\n\nDate: $date\nLocation: $location\n',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open an email app.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailCard(
            label: 'Event Info',
            child: Column(
              children: [
                _InfoRow(icon: Icons.calendar_today_outlined, text: date),
                const SizedBox(height: 6),
                _InfoRow(icon: Icons.location_on_outlined, text: location),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailCard(
            label: 'Attendees ($attendeeCount)',
            child: Column(
              children: [
                ..._attendees.map(
                  (a) => _AttendeeRow(
                    initials: a['initials']!,
                    name: a['name']!,
                    email: a['email']!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+ ${attendeeCount - _attendees.length} more attendees',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _sendReminder(context),
            icon: const Icon(Icons.mail_outline, size: 16),
            label: const Text('Send Email Reminder'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _DetailCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  const _AttendeeRow({
    required this.initials,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accent,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
