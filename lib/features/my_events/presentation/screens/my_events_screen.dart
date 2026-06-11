import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('My Events', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(16),
      children: [
        _MyEventCard(
          title: 'ALU Career Fair 2026',
          status: 'Approved',
          statusColor: AppColors.success,
          statusBg: AppColors.success,
          date: 'Jun 18 · 10:00 AM',
          location: 'Main Hall',
          footer: '47 attendees',
          actionLabel: 'View attendees',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendeeDetailScreen(
                title: 'ALU Career Fair 2026',
                date: 'Jun 18, 2026 · 10:00 AM – 5:00 PM',
                location: 'Main Hall, Kigali Campus',
                attendeeCount: 47,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _MyEventCard(
          title: 'Tech Talk: AI in Africa',
          status: 'Approved',
          statusColor: AppColors.success,
          statusBg: AppColors.success,
          date: 'Jun 25 · 2:00 PM',
          location: 'Room B3',
          footer: '23 attendees',
          actionLabel: 'View attendees',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendeeDetailScreen(
                title: 'Tech Talk: AI in Africa',
                date: 'Jun 25, 2026 · 2:00 PM – 4:00 PM',
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
      padding: const EdgeInsets.all(16),
      children: [
        _MyEventCard(
          title: 'Fintech Hackathon',
          status: 'Pending',
          statusColor: const Color(0xFFB8860B),
          statusBg: const Color(0xFFB8860B),
          date: 'Jul 5 · 9:00 AM',
          location: 'Innovation Lab',
          footer: 'Awaiting admin review',
          actionLabel: 'Edit',
          actionOutline: true,
          onAction: () {},
        ),
      ],
    );
  }

  Widget _buildCancelledTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Opacity(
          opacity: 0.6,
          child: _MyEventCard(
            title: 'Study Group: Data Structures',
            status: 'Cancelled',
            statusColor: AppColors.alert,
            statusBg: AppColors.alert,
            date: 'May 30 · 4:00 PM',
            location: 'Library',
            footer: 'Venue unavailable',
            actionLabel: '',
            onAction: null,
          ),
        ),
      ],
    );
  }
}

// ── My Event Card ─────────────────────────────────────────────────────────────

class _MyEventCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String date;
  final String location;
  final String footer;
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
    required this.actionLabel,
    this.actionOutline = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAction,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusBg.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  footer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                if (actionLabel.isNotEmpty)
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: actionOutline
                            ? AppColors.background
                            : AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: actionOutline
                              ? AppColors.border
                              : AppColors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: actionOutline
                              ? AppColors.textMuted
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attendee Detail Screen ────────────────────────────────────────────────────

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
            onPressed: () {},
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
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
