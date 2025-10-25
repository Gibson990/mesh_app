import 'dart:developer' as developer;
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionMode {
  offline,  // Bluetooth only
  online,   // Internet available
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectionMode>? _connectionModeController;
  ConnectionMode _currentMode = ConnectionMode.offline;

  Stream<ConnectionMode> get connectionModeStream {
    _connectionModeController ??= StreamController<ConnectionMode>.broadcast();
    return _connectionModeController!.stream;
  }

  ConnectionMode get currentMode => _currentMode;
  bool get isOnline => _currentMode == ConnectionMode.online;
  bool get isOffline => _currentMode == ConnectionMode.offline;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      developer.log('Connectivity check error: $e');
      _updateConnectionMode(ConnectionMode.offline);
    }
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    ConnectionMode newMode;

    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        newMode = ConnectionMode.online;
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
      default:
        newMode = ConnectionMode.offline;
        break;
    }

    if (newMode != _currentMode) {
      _updateConnectionMode(newMode);
    }
  }

  // Update connection mode
  void _updateConnectionMode(ConnectionMode mode) {
    _currentMode = mode;
    _connectionModeController?.add(mode);
    
    if (mode == ConnectionMode.online) {
      developer.log('Connection mode: ONLINE - Internet available');
    } else {
      developer.log('Connection mode: OFFLINE - Bluetooth mesh only');
    }
  }

  // Manually refresh connectivity status
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  // Dispose resources
  void dispose() {
    _connectionModeController?.close();
  }
}

