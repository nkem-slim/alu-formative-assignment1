import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const ALUApp());
}

class ALUApp extends StatelessWidget {
  const ALUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Intercampus Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800),
          surface: Color(0xFF1A1A1A),
        ),
        fontFamily: 'SF Pro Display',
      ),
      home: const ProfilePage(),
    );
  }
}

class UserProfile {
  String name;
  String email;
  String campus;
  String program;
  String bio;
  int eventsCount;
  int communitiesCount;
  int connectionsCount;

  UserProfile({
    required this.name,
    required this.email,
    required this.campus,
    required this.program,
    required this.bio,
    this.eventsCount = 23,
    this.communitiesCount = 5,
    this.connectionsCount = 87,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserProfile _user = UserProfile(
    name: 'Ange Umuhoza',
    email: 'a.umuhoza@alustudent.com',
    campus: 'Kigali Campus',
    program: 'BSc Software Engineering',
    bio: 'Passionate about tech for social impact. Building solutions for the world.',
  );

  bool _pushNotifications = true;
  bool _eventReminders = true;
  bool _communityUpdates = false;
  bool _newOpportunities = true;

  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _card = Color(0xFF1C1C1E);
  static const Color _gold = Color(0xFFFFB800);
  static const Color _goldDim = Color(0x33FFB800);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _divider = Color(0xFF2C2C2E);
  static const Color _danger = Color(0xFFFF453A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: _bg,
              pinned: true,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _showEditProfileSheet(context),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _buildAvatarSection(),

                  const SizedBox(height: 24),

                  _buildStatsRow(),

                  const SizedBox(height: 28),

                  _buildSectionLabel('ACCOUNT'),
                  _buildSettingsCard([
                    _buildTile(
                      icon: CupertinoIcons.person_fill,
                      label: 'Edit Profile',
                      onTap: () => _showEditProfileSheet(context),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: CupertinoIcons.lock_fill,
                      label: 'Change Password',
                      onTap: () => _showChangePasswordSheet(context),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildSectionLabel('NOTIFICATIONS'),
                  _buildSettingsCard([
                    _buildToggleTile(
                      icon: CupertinoIcons.bell_fill,
                      label: 'Push Notifications',
                      subtitle: 'Receive alerts on your device',
                      value: _pushNotifications,
                      onChanged: (v) =>
                          setState(() => _pushNotifications = v),
                    ),
                    _buildDivider(),
                    _buildToggleTile(
                      icon: CupertinoIcons.calendar_badge_plus,
                      label: 'Event Reminders',
                      subtitle: '1 hour before your RSVPs',
                      value: _eventReminders,
                      enabled: _pushNotifications,
                      onChanged: (v) =>
                          setState(() => _eventReminders = v),
                    ),
                    _buildDivider(),
                    _buildToggleTile(
                      icon: CupertinoIcons.person_3_fill,
                      label: 'Community Updates',
                      subtitle: 'New posts in your clubs',
                      value: _communityUpdates,
                      enabled: _pushNotifications,
                      onChanged: (v) =>
                          setState(() => _communityUpdates = v),
                    ),
                    _buildDivider(),
                    _buildToggleTile(
                      icon: CupertinoIcons.star_fill,
                      label: 'New Opportunities',
                      subtitle: 'Internships, competitions & more',
                      value: _newOpportunities,
                      enabled: _pushNotifications,
                      onChanged: (v) =>
                          setState(() => _newOpportunities = v),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildSectionLabel('ACCOUNT ACTIONS'),
                  _buildSettingsCard([
                    _buildTile(
                      icon: CupertinoIcons.square_arrow_right,
                      label: 'Sign Out',
                      labelColor: _danger,
                      iconColor: _danger,
                      showChevron: false,
                      onTap: () => _showSignOutDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF6B00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'AU',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditProfileSheet(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bg, width: 2),
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    size: 13,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _user.name,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user.campus,
          style: const TextStyle(
            color: _gold,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _user.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(_user.eventsCount.toString(), 'Events'),
          Container(width: 0.5, height: 36, color: _divider),
          _buildStat(_user.communitiesCount.toString(), 'Communities'),
          Container(width: 0.5, height: 36, color: _divider),
          _buildStat(_user.connectionsCount.toString(), 'Connections'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color labelColor = _textPrimary,
    Color iconColor = _gold,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: _textSecondary,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _gold, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value && enabled,
              activeColor: _gold,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 64),
      child: Divider(height: 0.5, thickness: 0.5, color: _divider),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _user.name);
    final campusCtrl = TextEditingController(text: _user.campus);
    final programCtrl = TextEditingController(text: _user.program);
    final bioCtrl = TextEditingController(text: _user.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        nameCtrl: nameCtrl,
        campusCtrl: campusCtrl,
        programCtrl: programCtrl,
        bioCtrl: bioCtrl,
        onSave: () {
          setState(() {
            _user.name = nameCtrl.text.trim();
            _user.campus = campusCtrl.text.trim();
            _user.program = programCtrl.text.trim();
            _user.bio = bioCtrl.text.trim();
          });
          Navigator.pop(context);
          _showSuccessSnack(context, 'Profile updated');
        },
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(
        onSave: () {
          Navigator.pop(context);
          _showSuccessSnack(context, 'Password changed');
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sign Out'),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnack(context, 'Signed out successfully');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill,
                color: _gold, size: 18),
            const SizedBox(width: 10),
            Text(message,
                style: const TextStyle(color: _textPrimary, fontSize: 14)),
          ],
        ),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _EditProfileSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController campusCtrl;
  final TextEditingController programCtrl;
  final TextEditingController bioCtrl;
  final VoidCallback onSave;

  const _EditProfileSheet({
    required this.nameCtrl,
    required this.campusCtrl,
    required this.programCtrl,
    required this.bioCtrl,
    required this.onSave,
  });

  static const Color _bg = Color(0xFF1C1C1E);
  static const Color _gold = Color(0xFFFFB800);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: _textSecondary)),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: onSave,
                    child: const Text('Save',
                        style: TextStyle(
                            color: _gold, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF3A3A3C)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildField('Full Name', nameCtrl, 'Your full name'),
                  const SizedBox(height: 14),
                  _buildField('Campus', campusCtrl, 'e.g. Kigali Campus'),
                  const SizedBox(height: 14),
                  _buildField('Program', programCtrl, 'Your degree program'),
                  const SizedBox(height: 14),
                  _buildField('Bio', bioCtrl, 'Tell your ALU story…',
                      maxLines: 3),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF48484A)),
            filled: true,
            fillColor: _fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  final VoidCallback onSave;

  const _ChangePasswordSheet({required this.onSave});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _error;

  static const Color _bg = Color(0xFF1C1C1E);
  static const Color _gold = Color(0xFFFFB800);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFF2C2C2E);
  static const Color _danger = Color(0xFFFF453A);

  void _validate() {
    if (_currentCtrl.text.isEmpty ||
        _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    if (_newCtrl.text.length < 8) {
      setState(() => _error = 'New password must be at least 8 characters.');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    setState(() => _error = null);
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: _textSecondary)),
                  ),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _validate,
                    child: const Text('Save',
                        style: TextStyle(
                            color: _gold, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF3A3A3C)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPasswordField(
                    'Current Password',
                    _currentCtrl,
                    _showCurrent,
                    () => setState(() => _showCurrent = !_showCurrent),
                  ),
                  const SizedBox(height: 14),
                  _buildPasswordField(
                    'New Password',
                    _newCtrl,
                    _showNew,
                    () => setState(() => _showNew = !_showNew),
                  ),
                  const SizedBox(height: 14),
                  _buildPasswordField(
                    'Confirm New Password',
                    _confirmCtrl,
                    _showConfirm,
                    () => setState(() => _showConfirm = !_showConfirm),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_circle,
                            color: _danger, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _error!,
                          style: const TextStyle(
                              color: _danger, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    bool visible,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: !visible,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: _fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: _textSecondary,
                size: 18,
              ),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}