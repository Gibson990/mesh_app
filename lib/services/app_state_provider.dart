import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:mesh_app/core/models/user.dart';
import 'package:mesh_app/services/storage/auth_service.dart';
import 'package:mesh_app/services/message_controller.dart';
import 'package:mesh_app/services/bluetooth/bluetooth_service.dart';
import 'package:mesh_app/services/connectivity/connectivity_service.dart';

class AppStateProvider extends ChangeNotifier {
  static final AppStateProvider _instance = AppStateProvider._internal();
  factory AppStateProvider() => _instance;
  AppStateProvider._internal();

  // Services
  final AuthService _authService = AuthService();
  final MessageController _messageController = MessageController();
  final BluetoothService _bluetoothService = BluetoothService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // App State
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _peerCount = 0;
  bool _isOnline = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get peerCount => _peerCount;
  bool get isOnline => _isOnline;
  User? get currentUser => _authService.currentUser;
  bool get isHigherAccess => _authService.isHigherAccess;

  // Initialize app state
  Future<void> initialize() async {
    if (_isInitialized) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize all services
      await _authService.initialize();
      await _connectivityService.initialize();
      await _messageController.initialize();

      // Initialize Bluetooth
      final bluetoothReady = await _bluetoothService.initialize();
      if (bluetoothReady) {
        await _bluetoothService.startScanning();
      }

      // Listen to peer count changes
      _bluetoothService.peerCountStream.listen((count) {
        _peerCount = count;
        notifyListeners();
      });

      // Listen to connectivity changes
      _connectivityService.connectionModeStream.listen((mode) {
        _isOnline = mode == ConnectionMode.online;
        notifyListeners();
      });

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      developer.log('App state initialized successfully');
    } catch (e) {
      developer.log('App initialization error: $e');
      setState(() {
        _errorMessage = 'Failed to initialize app: $e';
        _isLoading = false;
      });
    }
  }

  // Login as higher access user
  Future<bool> loginHigherAccess(String userId, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.loginHigherAccess(userId, password);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        return false;
      }
    } catch (e) {
      developer.log('Login error: $e');
      setState(() {
        _errorMessage = 'Login failed: $e';
        _isLoading = false;
      });
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();
      setState(() {
        _isLoading = false;
      });
      notifyListeners();
    } catch (e) {
      developer.log('Logout error: $e');
      setState(() {
        _errorMessage = 'Logout failed: $e';
        _isLoading = false;
      });
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Get message controller
  MessageController get messageController => _messageController;

  // Get Bluetooth service
  BluetoothService get bluetoothService => _bluetoothService;

  // Get connectivity service
  ConnectivityService get connectivityService => _connectivityService;

  // Dispose resources
  @override
  void dispose() {
    _messageController.dispose();
    _bluetoothService.dispose();
    _connectivityService.dispose();
    super.dispose();
  }
}
