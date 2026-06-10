import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const _keyCurrentUser = 'current_user';
  static const _keyUsers = 'registered_users';
  static const _keyOnboarding = 'onboarding_seen';

  UserModel? _currentUser;
  bool _onboardingSeen = false;
  bool _initialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get onboardingSeen => _onboardingSeen;
  bool get initialized => _initialized;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingSeen = prefs.getBool(_keyOnboarding) ?? false;
    final userJson = prefs.getString(_keyCurrentUser);
    if (userJson != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userJson));
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    _onboardingSeen = true;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final match = users.where(
      (u) =>
          u['email'] == email.trim().toLowerCase() &&
          u['password'] == password,
    );

    if (match.isEmpty) return 'Invalid email or password.';

    final u = match.first;
    _currentUser = UserModel(
      id: u['id'],
      name: u['name'],
      email: u['email'],
      phone: u['phone'] ?? '',
      campus: u['campus'],
      avatarInitials: _initials(u['name']),
    );
    await prefs.setString(_keyCurrentUser, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String campus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    if (users.any((u) => u['email'] == email.trim().toLowerCase())) {
      return 'An account with this email already exists.';
    }

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
      'campus': campus,
    };

    users.add(newUser);
    await prefs.setString(_keyUsers, jsonEncode(users));

    _currentUser = UserModel(
      id: newUser['id']!,
      name: newUser['name']!,
      email: newUser['email']!,
      phone: newUser['phone']!,
      campus: newUser['campus']!,
      avatarInitials: _initials(newUser['name']!),
    );
    await prefs.setString(_keyCurrentUser, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
    _currentUser = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> _loadUsers(SharedPreferences prefs) {
    final json = prefs.getString(_keyUsers);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
