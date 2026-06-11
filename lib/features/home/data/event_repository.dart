import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventRepository {
  static const _keyEvents = 'submitted_events';

  /// All submitted events regardless of status.
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyEvents);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  /// Only events waiting for admin review.
  static Future<List<Map<String, dynamic>>> getPendingEvents() async {
    final all = await getAllEvents();
    return all.where((e) => e['status'] == 'pending').toList();
  }

  /// Save a new event (status: 'pending').
  static Future<void> addEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    events.add(event);
    await prefs.setString(_keyEvents, jsonEncode(events));
  }

  /// Update status to 'approved' or 'rejected'.
  static Future<void> updateStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    final i = events.indexWhere((e) => e['id'] == id);
    if (i != -1) {
      events[i] = {...events[i], 'status': status};
      await prefs.setString(_keyEvents, jsonEncode(events));
    }
  }

  /// Events submitted by a specific organizer email.
  static Future<List<Map<String, dynamic>>> getEventsByOrganizer(
      String email) async {
    final all = await getAllEvents();
    return all
        .where((e) =>
            (e['organizerEmail'] as String?)?.toLowerCase() ==
            email.toLowerCase())
        .toList();
  }

  /// Registered users stored by AuthService.
  static Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('registered_users');
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }
}
