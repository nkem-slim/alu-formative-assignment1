import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/mock_events.dart';
import '../../../home/data/models/event_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const _attendedEventsKey = 'attended_event_ids';
  final Set<String> _attendedEventIds = {};
  final Set<String> _finishedEventIds = {'4', '7', '8'};

  List<Event> get _ongoingEvents => mockEvents
      .where((event) => !_finishedEventIds.contains(event.id))
      .toList();

  List<Event> get _finishedEvents => mockEvents
      .where((event) => _finishedEventIds.contains(event.id))
      .toList();

  @override
  void initState() {
    super.initState();
    _loadAttendedEvents();
  }

  Future<void> _loadAttendedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _attendedEventIds
        ..clear()
        ..addAll(prefs.getStringList(_attendedEventsKey) ?? const []);
    });
  }

  Future<void> _saveAttendedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_attendedEventsKey, _attendedEventIds.toList());
  }

  void _openDetails(Event event, EventRunState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _EventRunDetailScreen(
          event: event,
          state: state,
          attended: _attendedEventIds.contains(event.id),
          onAttendanceChanged: (attended) {
            setState(() {
              if (attended) {
                _attendedEventIds.add(event.id);
              } else {
                _attendedEventIds.remove(event.id);
              }
            });
            _saveAttendedEvents();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            const _EventsHeader(),
            const _EventsTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _EventRunList(
                    events: _ongoingEvents,
                    state: EventRunState.ongoing,
                    attendedEventIds: _attendedEventIds,
                    onOpenDetails: _openDetails,
                  ),
                  _EventRunList(
                    events: _finishedEvents,
                    state: EventRunState.finished,
                    attendedEventIds: _attendedEventIds,
                    onOpenDetails: _openDetails,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum EventRunState { ongoing, finished }

extension on EventRunState {
  String get label => switch (this) {
    EventRunState.ongoing => 'Ongoing',
    EventRunState.finished => 'Finished',
  };

  String get badgeLabel => switch (this) {
    EventRunState.ongoing => 'Live',
    EventRunState.finished => 'Closed',
  };

  Color get color => switch (this) {
    EventRunState.ongoing => AppColors.success,
    EventRunState.finished => AppColors.textMuted,
  };
}

class _EventsHeader extends StatelessWidget {
  const _EventsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Text('Events', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EventsTabBar extends StatelessWidget {
  const _EventsTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.accent,
        indicatorWeight: 3,
        dividerColor: AppColors.border,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: const [
          Tab(text: 'Ongoing'),
          Tab(text: 'Finished'),
        ],
      ),
    );
  }
}

class _EventRunList extends StatelessWidget {
  final List<Event> events;
  final EventRunState state;
  final Set<String> attendedEventIds;
  final void Function(Event event, EventRunState state) onOpenDetails;

  const _EventRunList({
    required this.events,
    required this.state,
    required this.attendedEventIds,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EmptyEventsState(state: state);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventRunCard(
          event: event,
          state: state,
          attended: attendedEventIds.contains(event.id),
          onTap: () => onOpenDetails(event, state),
        );
      },
    );
  }
}

class _EventRunCard extends StatelessWidget {
  final Event event;
  final EventRunState state;
  final bool attended;
  final VoidCallback onTap;

  const _EventRunCard({
    required this.event,
    required this.state,
    required this.attended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d - h:mm a').format(event.date);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
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
                    color: event.headerColor,
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
                            _StatePill(state: state),
                            const SizedBox(width: 8),
                            if (attended) const _AttendedPill(),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        _MetaRow(
                          icon: Icons.person_outline,
                          text: event.organizer,
                        ),
                        const SizedBox(height: 6),
                        _MetaRow(
                          icon: Icons.calendar_today_outlined,
                          text: date,
                        ),
                        const SizedBox(height: 6),
                        _MetaRow(
                          icon: Icons.location_on_outlined,
                          text: event.location,
                        ),
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

class _EventRunDetailScreen extends StatefulWidget {
  final Event event;
  final EventRunState state;
  final bool attended;
  final ValueChanged<bool> onAttendanceChanged;

  const _EventRunDetailScreen({
    required this.event,
    required this.state,
    required this.attended,
    required this.onAttendanceChanged,
  });

  @override
  State<_EventRunDetailScreen> createState() => _EventRunDetailScreenState();
}

class _EventRunDetailScreenState extends State<_EventRunDetailScreen> {
  late bool _attended = widget.attended;

  Future<void> _contactOrganizer() async {
    final event = widget.event;
    final uri = Uri(
      scheme: 'mailto',
      path: event.organizerEmail,
      query: 'subject=Question about ${Uri.encodeComponent(event.title)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open email for ${event.organizer}.')),
    );
  }

  void _toggleAttendance() {
    setState(() => _attended = !_attended);
    widget.onAttendanceChanged(_attended);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final date = DateFormat('EEEE, MMMM d, yyyy').format(event.date);
    final time = DateFormat('h:mm a').format(event.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: event.headerColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatePill(
                      state: widget.state,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    if (_attended)
                      const _AttendedPill(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.success,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Organized by ${event.organizer}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactOrganizer,
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Contact Organizer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _toggleAttendance,
            icon: Icon(
              _attended ? Icons.check_circle : Icons.how_to_reg_outlined,
            ),
            label: Text(_attended ? 'Attended' : 'Mark Attended'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _attended ? AppColors.success : AppColors.accent,
              foregroundColor: _attended ? Colors.white : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            children: [
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Organizer',
                value: event.organizer,
              ),
              const Divider(height: 22),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: date,
              ),
              const Divider(height: 22),
              _DetailRow(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: time,
              ),
              const Divider(height: 22),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: event.location,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            children: [
              Text('About', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  final EventRunState state;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _StatePill({
    required this.state,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = state.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.badgeLabel,
        style: TextStyle(
          color: foregroundColor ?? color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AttendedPill extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;

  const _AttendedPill({
    this.backgroundColor = const Color(0xFFEAF6F0),
    this.foregroundColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Checked in',
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

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

class _DetailPanel extends StatelessWidget {
  final List<Widget> children;

  const _DetailPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyEventsState extends StatelessWidget {
  final EventRunState state;

  const _EmptyEventsState({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 56, color: AppColors.border),
            const SizedBox(height: 14),
            Text(
              'No ${state.label.toLowerCase()} events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              state == EventRunState.ongoing
                  ? 'Active events will appear here when they are available.'
                  : 'Completed events will appear here after they close.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
