import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mesh_app/core/algorithms/compression_service.dart';
import 'package:mesh_app/core/algorithms/encryption_service.dart';
import 'package:mesh_app/core/constants/app_constants.dart';
import 'package:mesh_app/core/models/message.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final List<BluetoothDevice> _connectedDevices = [];

  
  StreamController<Message>? _messageStreamController;
  StreamController<int>? _peerCountController;
  
  bool _isScanning = false;

  Stream<Message> get messageStream {
    _messageStreamController ??= StreamController<Message>.broadcast();
    return _messageStreamController!.stream;
  }

  Stream<int> get peerCountStream {
    _peerCountController ??= StreamController<int>.broadcast();
    return _peerCountController!.stream;
  }

  int get connectedPeerCount => _connectedDevices.length;

  // Initialize Bluetooth service
  Future<bool> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        return false;
      }

      // Check adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Start scanning for nearby devices
  Future<void> startScanning() async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      
      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: AppConstants.bluetoothScanDuration,
      );

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          _handleDiscoveredDevice(result.device);
        }
      });

      // Auto-restart scanning after timeout
      Future.delayed(AppConstants.bluetoothScanDuration, () {
        _isScanning = false;
        if (_connectedDevices.length < AppConstants.maxMeshNodes) {
          startScanning();
        }
      });
    } catch (e) {
      _isScanning = false;
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
    } catch (e) {
      // Ignore errors
    }
  }

  // Handle discovered device
  void _handleDiscoveredDevice(BluetoothDevice device) async {
    if (_connectedDevices.contains(device)) return;
    if (_connectedDevices.length >= AppConstants.maxMeshNodes) return;

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevices.add(device);
      _updatePeerCount();
    } catch (e) {
      _connectedDevices.remove(device);
      _updatePeerCount();
    }
  }

  // Send message via Bluetooth mesh
  Future<bool> sendMessage(Message message) async {
    if (_connectedDevices.isEmpty) {
      return false;
    }

    try {
      final messageJson = message.toJson();
      final jsonString = jsonEncode(messageJson);
      final compressed = CompressionService.compressText(jsonString);
      EncryptionService.encryptBinary(compressed);
      
      // For demo purposes, we'll just mark as sent
      // In production, implement actual BLE characteristic writes
      return true;
    } catch (e) {
      return false;
    }
  }



  // Update peer count
  void _updatePeerCount() {
    _peerCountController?.add(_connectedDevices.length);
  }

  // Disconnect from all devices
  Future<void> disconnectAll() async {
    for (final device in _connectedDevices) {
      try {
        await device.disconnect();
      } catch (e) {
        // Ignore errors
      }
    }
    _connectedDevices.clear();
    _updatePeerCount();
  }

  // Dispose resources
  void dispose() {
    disconnectAll();
    _messageStreamController?.close();
    _peerCountController?.close();
  }
}

