import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/event_icons.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/event_repository.dart';

class CreateEventScreen extends StatefulWidget {
  final AuthService authService;
  const CreateEventScreen({super.key, required this.authService});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String _location = 'Main Hall';
  String _role = 'Student';
  bool _isPaid = false;
  bool _hasFood = false;
  bool _isOnCampus = true;
  String _selectedIcon = 'school';
  bool _submitting = false;

  static const _locations = [
    'Main Hall',
    'Innovation Lab',
    'Room A2',
    'Room B3',
    'Library',
    'Auditorium',
    'Cafeteria',
    'Online',
    'Other',
  ];

  static const _roles = [
    'Student',
    'SRC Member',
    'KMC Member',
    'Staff',
    'Faculty',
    'Club Leader',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Pickers ──────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.accent,
            onSecondary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      _snack('Please select a date');
      return;
    }
    if (_time == null) {
      _snack('Please select a time');
      return;
    }

    setState(() => _submitting = true);

    final user = widget.authService.currentUser;
    final dateStr =
        '${_date!.day} ${_month(_date!.month)} · ${_time!.format(context)}';

    await EventRepository.addEvent({
      'id': 'event_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'organizerName': user?.name ?? '',
      'organizerEmail': user?.email ?? '',
      'organizerRole': _role,
      'date': dateStr,
      'location': _location,
      'isPaid': _isPaid,
      'price': _isPaid ? double.tryParse(_priceCtrl.text.trim()) : null,
      'hasFood': _hasFood,
      'isOnCampus': _isOnCampus,
      'iconName': _selectedIcon,
      'status': 'pending',
      'submittedAt': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    setState(() => _submitting = false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Event Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your event has been sent for admin review. You\'ll be notified once it\'s approved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text(
              'Done',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          'Create Event',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Icon selector ────────────────────────────────────────────────
            _Card(
              label: 'Event Icon',
              child: SizedBox(
                height: 68,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: EventIcons.map.entries.map((e) {
                    final sel = e.key == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 58,
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                sel ? AppColors.primary : AppColors.border,
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          e.value,
                          size: 26,
                          color: sel ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Event details ────────────────────────────────────────────────
            _Card(
              label: 'Event Details',
              child: Column(
                children: [
                  _FieldLabel(
                    label: 'Title',
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: _dec('e.g. Tech Startup Showcase'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter event title'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(
                    label: 'Description',
                    child: TextFormField(
                      controller: _descCtrl,
                      decoration:
                          _dec('Describe what the event is about...'),
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a description'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Date & time ──────────────────────────────────────────────────
            _Card(
              label: 'Date & Time',
              child: Column(
                children: [
                  _PickerTile(
                    icon: Icons.calendar_today_outlined,
                    text: _date == null
                        ? 'Select date'
                        : '${_date!.day} ${_month(_date!.month)} ${_date!.year}',
                    isPlaceholder: _date == null,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Icons.access_time_outlined,
                    text: _time == null
                        ? 'Select time'
                        : _time!.format(context),
                    isPlaceholder: _time == null,
                    onTap: _pickTime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Location ─────────────────────────────────────────────────────
            _Card(
              label: 'Location',
              child: _Dropdown(
                value: _location,
                items: _locations,
                onChanged: (v) => setState(() => _location = v!),
              ),
            ),
            const SizedBox(height: 12),

            // ── Organizer ────────────────────────────────────────────────────
            _Card(
              label: 'Organizer',
              child: Column(
                children: [
                  _FieldLabel(
                    label: 'Your Name',
                    child: TextFormField(
                      initialValue: user?.name ?? '',
                      readOnly: true,
                      decoration: _dec('').copyWith(
                        filled: true,
                        fillColor: AppColors.border.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(
                    label: 'Your Position',
                    child: _Dropdown(
                      value: _role,
                      items: _roles,
                      onChanged: (v) => setState(() => _role = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Event type ───────────────────────────────────────────────────
            _Card(
              label: 'Event Type',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Chip(
                        label: 'Free',
                        selected: !_isPaid,
                        onTap: () => setState(() => _isPaid = false),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label: 'Paid',
                        selected: _isPaid,
                        onTap: () => setState(() => _isPaid = true),
                      ),
                    ],
                  ),
                  if (_isPaid) ...[
                    const SizedBox(height: 12),
                    _FieldLabel(
                      label: 'Price (RWF)',
                      child: TextFormField(
                        controller: _priceCtrl,
                        decoration: _dec('e.g. 5000'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (!_isPaid) return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a price';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  _Toggle(
                    label: 'With Food',
                    value: _hasFood,
                    onChanged: (v) => setState(() => _hasFood = v),
                  ),
                  _Toggle(
                    label: 'On Campus',
                    value: _isOnCampus,
                    onChanged: (v) => setState(() => _isOnCampus = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ───────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Submit for Review',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.alert),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.alert, width: 1.5),
        ),
      );
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String label;
  final Widget child;
  const _Card({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _PickerTile(
      {required this.icon,
      required this.text,
      required this.isPlaceholder,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isPlaceholder
                    ? AppColors.textMuted
                    : AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown(
      {required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textDark),
          items: items
              .map((s) =>
                  DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textDark)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.accent,
        ),
      ],
    );
  }
}
