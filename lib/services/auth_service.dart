import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'db_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DbService _dbService = DbService();
  User? _currentUser;
  String? _authToken;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  Future<bool> login(String email, String password) async {
    try {
      final user = await _dbService.getUserByEmail(email);
      if (user == null) {
        throw Exception('User not found');
      }

      // NOTE: For a real app, never store plain passwords.
      // This demo compares the stored plain text password.
      final dbUser = await (await _dbService.database).query(
        'users',
        columns: ['password'],
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
        limit: 1,
      );

      if (dbUser.isEmpty || dbUser.first['password'] != password) {
        throw Exception('Invalid email or password');
      }

      _currentUser = user;
      // Generate a dummy token for local auth
      _authToken = 'local-${user.id}';

      if (_authToken != null) {
        await _secureStorage.write(key: 'auth_token', value: _authToken);
        await _saveUser(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> register(
      String email, String password, String name, String? phone) async {
    try {
      final existing = await _dbService.getUserByEmail(email);
      if (existing != null) {
        throw Exception('Email already registered');
      }

      final now = DateTime.now();
      final user = User(
        id: now.millisecondsSinceEpoch.toString(),
        email: email,
        phone: phone,
        name: name,
        role: UserRole.farmer,
        createdAt: now,
      );

      await _dbService.insertUser(user, password: password);

      _currentUser = user;
      _authToken = 'local-${user.id}';

      if (_authToken != null) {
        await _secureStorage.write(key: 'auth_token', value: _authToken);
        await _saveUser(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<bool> checkAuthStatus() async {
    try {
      _authToken = await _secureStorage.read(key: 'auth_token');
      if (_authToken != null) {
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString('user_data');
        if (userJson != null) {
          // In a real app, you might want to verify the token with the server
          // For now, we'll just restore from local storage
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<User?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _currentUser = User.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>);
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

