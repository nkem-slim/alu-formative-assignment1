import 'package:flutter/material.dart';

void main() {
  runApp(const CampusEventsApp());
}

class CampusEventsApp extends StatelessWidget {
  const CampusEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5C732)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2; // Start on "My Events"

  final List<Widget> _screens = const [
    Center(child: Text('Home Screen', style: TextStyle(fontSize: 18))),
    EventsScreen(),
    MyEventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const yellow = Color(0xFFF5C732);
    const items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Events'},
      {'icon': Icons.event_available_outlined, 'label': 'My Events'},
      {'icon': Icons.account_circle_outlined, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: List.generate(items.length, (i) {
          final isActive = _currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isActive && i == 2
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: yellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(items[i]['icon'] as IconData,
                              color: Colors.black, size: 22),
                        )
                      : Icon(
                          items[i]['icon'] as IconData,
                          color: isActive ? Colors.black : Colors.grey,
                          size: 22,
                        ),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('My Events',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            Text('Manage your submitted events',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          indicatorColor: const Color(0xFFF5C732),
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Approved'),
            Tab(text: 'Pending'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApprovedTab(context),
          _buildPendingTab(),
          _buildCancelledTab(),
        ],
      ),
    );
  }

  Widget _buildApprovedTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EventCard(
          title: 'ALU Career Fair 2026',
          status: 'Approved',
          statusColor: const Color(0xFF2E7D32),
          statusBg: const Color(0xFFE8F5E9),
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
        EventCard(
          title: 'Tech Talk: AI in Africa',
          status: 'Approved',
          statusColor: const Color(0xFF2E7D32),
          statusBg: const Color(0xFFE8F5E9),
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
        EventCard(
          title: 'Fintech Hackathon',
          status: 'Pending',
          statusColor: const Color(0xFFB8860B),
          statusBg: const Color(0xFFFFF8E1),
          date: 'Jul 5 · 9:00 AM',
          location: 'Innovation Lab',
          footer: 'Awaiting review',
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
          opacity: 0.7,
          child: EventCard(
            title: 'Study Group: Data Structures',
            status: 'Cancelled',
            statusColor: const Color(0xFFC62828),
            statusBg: const Color(0xFFFCE4EC),
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

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Events',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            Text("Discover what's happening on campus",
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          ],
        ),
      ),
      body: ListView(
        children: [
          _sectionLabel('Ongoing'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: EventCard(
              title: 'ALU Career Fair 2026',
              status: 'Ongoing',
              statusColor: const Color(0xFF1565C0),
              statusBg: const Color(0xFFE3F2FD),
              date: 'Ends at 5:00 PM',
              location: 'Main Hall',
              footer: 'Organized by Career Office',
              actionLabel: 'Details',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventDetailScreen()),
              ),
            ),
          ),
          _sectionLabel('Finished'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Opacity(
              opacity: 0.8,
              child: EventCard(
                title: 'Design Sprint Workshop',
                status: 'Finished',
                statusColor: const Color(0xFF6A1B9A),
                statusBg: const Color(0xFFF3E5F5),
                date: 'Jun 9 · 10:00 AM',
                location: 'Lab 2',
                footer: '128 attended',
                actionLabel: 'Details',
                actionOutline: true,
                onAction: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Opacity(
              opacity: 0.8,
              child: EventCard(
                title: 'Kigali Startup Pitch',
                status: 'Finished',
                statusColor: const Color(0xFF6A1B9A),
                statusBg: const Color(0xFFF3E5F5),
                date: 'Jun 3 · 3:00 PM',
                location: 'Auditorium',
                footer: '84 attended',
                actionLabel: 'Details',
                actionOutline: true,
                onAction: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C2C2C),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('NV',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Nkem Vincent Nweke',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 2),
                  const Text('n.nweke@alustudent.com',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  const Text('0795019913',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Kigali Campus',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF555555))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Menu items
            _menuItem(Icons.article_outlined, 'My Posts'),
            _menuItem(Icons.bookmark_border, 'Saved'),
            _menuItem(Icons.notifications_none, 'Notifications'),
            _menuItem(Icons.settings_outlined, 'Account Settings'),
            _menuItem(Icons.help_outline, 'Help & Support'),
            const SizedBox(height: 10),
            _menuItem(Icons.logout, 'Sign Out', isRed: true, showChevron: false),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label,
      {bool isRed = false, bool showChevron = true}) {
    final color = isRed ? const Color(0xFFE53935) : const Color(0xFF1A1A1A);
    final iconColor = isRed ? const Color(0xFFE53935) : const Color(0xFF555555);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2))),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(label, style: TextStyle(fontSize: 14, color: color)),
        trailing: showChevron
            ? const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 18)
            : null,
        onTap: () {},
      ),
    );
  }
}

class EventCard extends StatelessWidget {
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

  const EventCard({
    super.key,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Meta row
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(date,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(location,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),
            // Footer row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(footer,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
                if (actionLabel.isNotEmpty)
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: actionOutline
                            ? const Color(0xFFF7F7F7)
                            : const Color(0xFFFFFBEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: actionOutline
                              ? const Color(0xFF555555)
                              : const Color(0xFFF5C732),
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
      'email': 'b.mutesi@alustudent.com'
    },
    {
      'initials': 'CJ',
      'name': 'Claude Jabari',
      'email': 'c.jabari@alustudent.com'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event info card
          _detailCard(
            label: 'Event Info',
            child: Column(
              children: [
                _infoRow(Icons.calendar_today_outlined, date),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined, location),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Attendees card
          _detailCard(
            label: 'Attendees ($attendeeCount)',
            child: Column(
              children: [
                ..._attendees.map((a) => _attendeeRow(
                    a['initials']!, a['name']!, a['email']!,
                    bg: const Color(0xFFF5C732),
                    textColor: const Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                Text(
                  '+ ${attendeeCount - _attendees.length} more attendees',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFAAAAAA)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail_outline, size: 16),
              label: const Text('Send email reminder',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C732),
                foregroundColor: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({required String label, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAAAAAA),
                  letterSpacing: 0.6)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF555555)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
      ],
    );
  }

  Widget _attendeeRow(String initials, String name, String email,
      {required Color bg, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A1A))),
              Text(email,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF999999))),
            ],
          ),
        ],
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ALU Career Fair 2026',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // About card
          _card(
            label: 'About',
            child: const Text(
              'Connect with leading companies hiring ALU students. Bring your CV and meet recruiters from 20+ organizations across East Africa.',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          // Organizer card
          _card(
            label: 'Organizer',
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('CO',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB8860B))),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Career Office',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF1A1A1A))),
                        Text('careers@alueducation.com',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF999999))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message_outlined, size: 14),
                    label: const Text('Contact organizer',
                        style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF555555),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark as attended',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C732),
                foregroundColor: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String label, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAAAAAA),
                  letterSpacing: 0.6)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}