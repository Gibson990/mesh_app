import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mesh_app/core/models/user.dart';
import 'package:mesh_app/core/constants/app_constants.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _currentUserKey = 'current_user';
  static const String _isHigherAccessKey = 'is_higher_access';

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isHigherAccess => _currentUser?.isHigherAccess ?? false;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadCurrentUser();
  }

  // Load current user from storage
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      } else {
        // Create anonymous user if none exists
        _currentUser = User.anonymous();
        await _saveCurrentUser(_currentUser!);
      }
    } catch (e) {
      developer.log('Load user error: $e');
      _currentUser = User.anonymous();
    }
  }

  // Save current user to storage
  Future<void> _saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_currentUserKey, userJson);
      await prefs.setBool(_isHigherAccessKey, user.isHigherAccess);
    } catch (e) {
      developer.log('Save user error: $e');
    }
  }

  // Login as higher-access user
  Future<bool> loginHigherAccess(String userId, String password) async {
    try {
      // Verify credentials
      if (!AppConstants.higherAccessCredentials.containsKey(userId)) {
        return false;
      }

      if (AppConstants.higherAccessCredentials[userId] != password) {
        return false;
      }

      // Create higher-access user
      _currentUser = User.higherAccess(userId, userId);
      await _saveCurrentUser(_currentUser!);

      return true;
    } catch (e) {
      developer.log('Login error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Revert to anonymous user
      _currentUser = User.anonymous();
      await _saveCurrentUser(_currentUser!);
    } catch (e) {
      developer.log('Logout error: $e');
    }
  }

  // Update user reputation
  Future<void> updateReputation(int delta) async {
    if (_currentUser == null) return;

    try {
      final newScore = _currentUser!.reputationScore + delta;
      _currentUser = _currentUser!.copyWith(reputationScore: newScore);
      await _saveCurrentUser(_currentUser!);
    } catch (e) {
      developer.log('Update reputation error: $e');
    }
  }

  // Check if user is muted (low reputation)
  bool isMuted() {
    if (_currentUser == null) return false;
    return _currentUser!.reputationScore <= AppConstants.muteThreshold;
  }

  // Check if user is trusted (high reputation)
  bool isTrusted() {
    if (_currentUser == null) return false;
    return _currentUser!.reputationScore >= AppConstants.trustedThreshold;
  }

  // Rotate user ID (for anonymity)
  Future<void> rotateUserId() async {
    if (_currentUser == null || _currentUser!.isHigherAccess) return;

    try {
      // Generate new anonymous user
      final newUser = User.anonymous();
      _currentUser = newUser;
      await _saveCurrentUser(newUser);
    } catch (e) {
      developer.log('Rotate user ID error: $e');
    }
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_isHigherAccessKey);
      _currentUser = null;
    } catch (e) {
      developer.log('Clear auth data error: $e');
    }
  }
}

