import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/event_icons.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/home/data/event_repository.dart';

class MyEventsScreen extends StatefulWidget {
  final AuthService authService;
  const MyEventsScreen({super.key, required this.authService});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _rejected = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final email = widget.authService.currentUser?.email ?? '';
    final events = await EventRepository.getEventsByOrganizer(email);
    if (mounted) {
      setState(() {
        _approved =
            events.where((e) => e['status'] == 'approved').toList();
        _pending =
            events.where((e) => e['status'] == 'pending').toList();
        _rejected =
            events.where((e) => e['status'] == 'rejected').toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            color: AppColors.surface,
            child: Text(
              'My Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // ── Tab bar ──────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              dividerColor: AppColors.border,
              tabs: [
                Tab(text: 'Approved (${_approved.length})'),
                Tab(text: 'Pending (${_pending.length})'),
                Tab(text: 'Rejected (${_rejected.length})'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_approved, 'approved'),
                        _buildList(_pending, 'pending'),
                        _buildList(_rejected, 'rejected'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> events, String status) {
    if (events.isEmpty) {
      final (icon, label) = switch (status) {
        'approved' => (Icons.check_circle_outline, 'No approved events yet'),
        'pending' => (Icons.hourglass_empty_outlined, 'No pending events'),
        _ => (Icons.cancel_outlined, 'No rejected events'),
      };
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(icon, size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = events[i];
        return _MyEventCard(event: e);
      },
    );
  }
}

// ── My Event Card ─────────────────────────────────────────────────────────────

class _MyEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _MyEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final status = event['status'] as String? ?? 'pending';
    final (statusLabel, statusColor) = switch (status) {
      'approved' => ('Approved', AppColors.success),
      'rejected' => ('Rejected', AppColors.alert),
      _ => ('Pending', const Color(0xFFB8860B)),
    };

    final title = event['title'] as String? ?? '';
    final date = event['date'] as String? ?? '';
    final location = event['location'] as String? ?? '';
    final iconName = event['iconName'] as String? ?? 'school';
    final isPaid = event['isPaid'] == true;
    final hasFood = event['hasFood'] == true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(EventIcons.get(iconName),
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
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
          // ── Date & location ──────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(date,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          // ── Tags row ─────────────────────────────────────────────────
          Row(
            children: [
              _Tag(isPaid ? 'Paid' : 'Free',
                  isPaid ? AppColors.primary : AppColors.success),
              if (hasFood) ...[
                const SizedBox(width: 6),
                _Tag('Food', AppColors.textMuted),
              ],
              const Spacer(),
              if (status == 'pending')
                Text(
                  'Awaiting admin review',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              if (status == 'rejected')
                Text(
                  'Not approved by admin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11, color: AppColors.alert),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
