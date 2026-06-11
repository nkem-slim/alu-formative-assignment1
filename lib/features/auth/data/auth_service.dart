import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const _keyCurrentUser = 'current_user';
  static const _keyUsers = 'registered_users';
  static const _keyOnboarding = 'onboarding_seen';
  static const _seedUsers = [
    {
      'id': 'seed_user_1',
      'name': 'Amara Kone',
      'email': 'a.kone@alustudent.com',
      'phone': '+250 788 100 201',
      'password': 'student123',
      'campus': 'Kigali Campus',
    },
    {
      'id': 'seed_user_2',
      'name': 'Beatrice Mutesi',
      'email': 'b.mutesi@alustudent.com',
      'phone': '+250 788 100 202',
      'password': 'student123',
      'campus': 'Mauritius Campus',
    },
  ];

  static String get _adminEmail =>
      dotenv.env['ADMIN_EMAIL'] ?? 'admin@gmail.com';
  static String get _adminPassword =>
      dotenv.env['ADMIN_PASSWORD'] ?? 'adminpassword123';

  UserModel? _currentUser;
  bool _onboardingSeen = false;
  bool _initialized = false;

  static final _aluEmailRegex = RegExp(r'^[\w.+-]+@alustudent\.com$');

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.email == _adminEmail;
  bool get onboardingSeen => _onboardingSeen;
  bool get initialized => _initialized;

  /// Returns true for the admin email or any @alustudent.com address.
  bool isValidLoginEmail(String email) {
    final e = email.trim().toLowerCase();
    return e == _adminEmail || _aluEmailRegex.hasMatch(e);
  }

  /// Returns true only for @alustudent.com addresses (used on sign-up).
  bool isValidStudentEmail(String email) =>
      _aluEmailRegex.hasMatch(email.trim().toLowerCase());

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    await _seedUsersIfNeeded(prefs);
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

    // Admin shortcut — bypasses the registered-users list
    if (email.trim().toLowerCase() == _adminEmail &&
        password == _adminPassword) {
      _currentUser = UserModel(
        id: 'admin',
        name: 'Admin',
        email: _adminEmail,
        phone: '',
        campus: 'All Campuses',
        avatarInitials: 'AD',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyCurrentUser,
        jsonEncode(_currentUser!.toJson()),
      );
      notifyListeners();
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await _seedUsersIfNeeded(prefs);
    final users = _loadUsers(prefs);
    final normalizedEmail = email.trim().toLowerCase();

    final match = users.where(
      (u) =>
          u['email']?.toString().toLowerCase() == normalizedEmail &&
          u['password']?.toString() == password,
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
    await _seedUsersIfNeeded(prefs);
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
    return null;
  }

  Future<List<UserModel>> registeredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await _seedUsersIfNeeded(prefs);
    return _loadUsers(prefs)
        .map(
          (u) => UserModel(
            id: u['id'],
            name: u['name'],
            email: u['email'],
            phone: u['phone'] ?? '',
            campus: u['campus'],
            avatarInitials: _initials(u['name']),
          ),
        )
        .toList();
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String campus,
  }) async {
    if (_currentUser == null) return 'You need to sign in again.';

    final normalizedEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    if (cleanName.isEmpty) return 'Enter your full name.';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'Enter a valid email address.';
    }

    final prefs = await SharedPreferences.getInstance();
    await _seedUsersIfNeeded(prefs);

    if (isAdmin) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: cleanName,
        email: _currentUser!.email,
        phone: cleanPhone,
        campus: campus,
        avatarInitials: _initials(cleanName),
      );
      await prefs.setString(
        _keyCurrentUser,
        jsonEncode(_currentUser!.toJson()),
      );
      notifyListeners();
      return null;
    }

    final users = _loadUsers(prefs);
    final duplicate = users.any(
      (u) => u['id'] != _currentUser!.id && u['email'] == normalizedEmail,
    );
    if (duplicate) return 'An account with this email already exists.';

    final index = users.indexWhere((u) => u['id'] == _currentUser!.id);
    if (index == -1) return 'Could not find your account.';

    users[index] = {
      ...users[index],
      'name': cleanName,
      'email': normalizedEmail,
      'phone': cleanPhone,
      'campus': campus,
    };

    _currentUser = UserModel(
      id: _currentUser!.id,
      name: cleanName,
      email: normalizedEmail,
      phone: cleanPhone,
      campus: campus,
      avatarInitials: _initials(cleanName),
    );

    await prefs.setString(_keyUsers, jsonEncode(users));
    await prefs.setString(_keyCurrentUser, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
    return null;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return 'You need to sign in again.';
    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters.';
    }

    if (isAdmin) {
      if (currentPassword != _adminPassword) {
        return 'Current password is incorrect.';
      }
      return 'Admin password is configured in .env for this demo.';
    }

    final prefs = await SharedPreferences.getInstance();
    await _seedUsersIfNeeded(prefs);
    final users = _loadUsers(prefs);
    final index = users.indexWhere((u) => u['id'] == _currentUser!.id);
    if (index == -1) return 'Could not find your account.';
    if (users[index]['password'] != currentPassword) {
      return 'Current password is incorrect.';
    }

    users[index] = {...users[index], 'password': newPassword};
    await prefs.setString(_keyUsers, jsonEncode(users));
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
    return (jsonDecode(json) as List)
        .map((user) => Map<String, dynamic>.from(user as Map))
        .toList();
  }

  Future<void> _seedUsersIfNeeded(SharedPreferences prefs) async {
    final encodedUsers = prefs.getString(_keyUsers);
    var users = <Map<String, dynamic>>[];
    var shouldSave = encodedUsers == null;

    if (encodedUsers != null) {
      try {
        users = (jsonDecode(encodedUsers) as List)
            .map((user) => Map<String, dynamic>.from(user as Map))
            .toList();
      } catch (_) {
        shouldSave = true;
      }
    }

    for (final seedUser in _seedUsers) {
      final seedId = seedUser['id'];
      final seedEmail = seedUser['email']?.toString().toLowerCase();
      final exists = users.any(
        (user) =>
            user['id'] == seedId ||
            user['email']?.toString().toLowerCase() == seedEmail,
      );

      if (!exists) {
        users.add(Map<String, dynamic>.from(seedUser));
        shouldSave = true;
      }
    }

    if (shouldSave) {
      await prefs.setString(_keyUsers, jsonEncode(users));
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
