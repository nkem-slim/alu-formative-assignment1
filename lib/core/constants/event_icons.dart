import 'package:flutter/material.dart';

class EventIcons {
  EventIcons._();

  static const Map<String, IconData> map = {
    'school': Icons.school_outlined,
    'computer': Icons.computer_outlined,
    'palette': Icons.palette_outlined,
    'music': Icons.music_note_outlined,
    'sports': Icons.sports_soccer_outlined,
    'food': Icons.restaurant_outlined,
    'business': Icons.business_center_outlined,
    'science': Icons.science_outlined,
    'group': Icons.groups_outlined,
    'mic': Icons.mic_outlined,
    'trophy': Icons.emoji_events_outlined,
    'globe': Icons.public_outlined,
    'camera': Icons.camera_alt_outlined,
    'code': Icons.code_outlined,
    'health': Icons.health_and_safety_outlined,
    'finance': Icons.account_balance_outlined,
  };

  static IconData get(String name) => map[name] ?? Icons.event_outlined;
}
