import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    // Don't call checkAuthStatus here - it's handled by AuthWrapper
    // to avoid calling notifyListeners during build phase
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    // Don't notify here to avoid calling during build phase
    // We'll notify after the check is complete

    try {
      final isAuth = await _authService.checkAuthStatus();
      if (isAuth) {
        _user = await _authService.loadUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Use addPostFrameCallback to ensure notifyListeners is called after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        _user = _authService.currentUser;
        _error = null;
        return true;
      } else {
        _error = 'Login failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(email, password, name, phone);
      if (success) {
        _user = _authService.currentUser;
        _error = null;
        return true;
      } else {
        _error = 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
