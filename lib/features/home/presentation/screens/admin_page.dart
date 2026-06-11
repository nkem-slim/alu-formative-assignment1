import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/models/user_model.dart';

class AdminPage extends StatefulWidget {
  final AuthService authService;

  const AdminPage({super.key, required this.authService});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  static const _adminDecisionsKey = 'admin_event_decisions';
  late TabController _tabController;
  final Map<int, String> _decisions = {};
  List<UserModel> _registeredUsers = [];
  bool _loadingUsers = true;

  static const _pendingEvents = [
    {
      'title': 'Tech Startup Showcase',
      'organizer': 'ALU Innovation Club',
      'date': 'Jul 10 · 1:00 PM',
      'location': 'Innovation Lab',
      'type': 'On Campus',
    },
    {
      'title': 'Photography Workshop',
      'organizer': 'Creative Arts Society',
      'date': 'Jul 15 · 10:00 AM',
      'location': 'Room A2',
      'type': 'Free',
    },
    {
      'title': 'Debate Night: AI Ethics',
      'organizer': 'Philosophy Circle',
      'date': 'Jul 20 · 5:00 PM',
      'location': 'Main Hall',
      'type': 'Free',
    },
  ];

  static const _users = [
    {
      'initials': 'AK',
      'name': 'Amara Kone',
      'email': 'a.kone@alustudent.com',
      'campus': 'Kigali',
    },
    {
      'initials': 'BM',
      'name': 'Beatrice Mutesi',
      'email': 'b.mutesi@alustudent.com',
      'campus': 'Kigali',
    },
    {
      'initials': 'CJ',
      'name': 'Claude Jabari',
      'email': 'c.jabari@alustudent.com',
      'campus': 'Mauritius',
    },
    {
      'initials': 'DS',
      'name': 'David Sow',
      'email': 'd.sow@alustudent.com',
      'campus': 'Kigali',
    },
    {
      'initials': 'EN',
      'name': 'Emeka Nwosu',
      'email': 'e.nwosu@alustudent.com',
      'campus': 'Lagos',
    },
  ];

  int get _pendingCount => _pendingEvents.length - _decisions.length;
  int get _userCount =>
      _registeredUsers.isEmpty ? _users.length : _registeredUsers.length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadDecisions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await widget.authService.registeredUsers();
    if (!mounted) return;
    setState(() {
      _registeredUsers = users;
      _loadingUsers = false;
    });
  }

  Future<void> _loadDecisions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_adminDecisionsKey);
    if (encoded == null) return;

    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      _decisions
        ..clear()
        ..addAll(
          decoded.map(
            (key, value) => MapEntry(int.parse(key), value as String),
          ),
        );
    });
  }

  Future<void> _setDecision(int index, String decision) async {
    setState(() => _decisions[index] = decision);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _adminDecisionsKey,
      jsonEncode(_decisions.map((key, value) => MapEntry('$key', value))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (_pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8860B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFB8860B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '$_pendingCount pending',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tab bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              dividerColor: AppColors.border,
              tabs: [
                Tab(text: 'Pending ($_pendingCount)'),
                Tab(text: 'Users ($_userCount)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPendingTab(), _buildUsersTab()],
            ),
          ),
        ],
      ),
    );
  }

  // Pending tab

  Widget _buildPendingTab() {
    if (_decisions.length == _pendingEvents.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'All events reviewed',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingEvents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = _pendingEvents[i];
        final decision = _decisions[i];
        return _PendingEventCard(
          title: e['title']!,
          organizer: e['organizer']!,
          date: e['date']!,
          location: e['location']!,
          type: e['type']!,
          decision: decision,
          onApprove: decision == null
              ? () => _setDecision(i, 'approved')
              : null,
          onReject: decision == null ? () => _setDecision(i, 'rejected') : null,
        );
      },
    );
  }

  // Users tab

  Widget _buildUsersTab() {
    if (_loadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_registeredUsers.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _registeredUsers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final user = _registeredUsers[i];
            return _UserCard(
              initials: user.avatarInitials,
              name: user.name,
              email: user.email,
              campus: user.campus,
            );
          },
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final u = _users[i];
        return _UserCard(
          initials: u['initials']!,
          name: u['name']!,
          email: u['email']!,
          campus: u['campus']!,
        );
      },
    );
  }
}

// Pending Event Card

class _PendingEventCard extends StatelessWidget {
  final String title;
  final String organizer;
  final String date;
  final String location;
  final String type;
  final String? decision;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PendingEventCard({
    required this.title,
    required this.organizer,
    required this.date,
    required this.location,
    required this.type,
    this.decision,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: decision != null ? 0.65 : 1.0,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by $organizer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                  size: 12,
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
                  size: 12,
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
            if (decision == null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      // icon: const Icon(Icons.close, size: 14),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.alert,
                        side: BorderSide(
                          color: AppColors.alert.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      // icon: const Icon(Icons.check, size: 14),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (decision == 'approved'
                                ? AppColors.success
                                : AppColors.alert)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (decision == 'approved'
                                  ? AppColors.success
                                  : AppColors.alert)
                              .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    decision == 'approved' ? 'Approved' : 'Rejected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: decision == 'approved'
                          ? AppColors.success
                          : AppColors.alert,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// User Card

class _UserCard extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String campus;

  const _UserCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.campus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              campus,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
