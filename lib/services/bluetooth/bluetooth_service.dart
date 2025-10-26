import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mesh_app/core/algorithms/compression_service.dart';
import 'package:mesh_app/core/algorithms/encryption_service.dart';
import 'package:mesh_app/core/constants/app_constants.dart';
import 'package:mesh_app/core/models/message.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Mesh App UUIDs for BLE communication
  static const String serviceUuid = '0000180a-0000-1000-8000-00805f9b34fb';
  static const String messageCharacteristicUuid = '00002a29-0000-1000-8000-00805f9b34fb';
  
  final List<BluetoothDevice> _connectedDevices = [];
  final List<Map<String, dynamic>> _discoveredDevices = [];
  final Set<String> _processedMessageHashes = {}; // Prevent duplicate processing

  
  StreamController<Message>? _messageStreamController;
  StreamController<int>? _peerCountController;
  StreamController<List<Map<String, dynamic>>>? _discoveredDevicesController;
  
  bool _isScanning = false;

  Stream<Message> get messageStream {
    _messageStreamController ??= StreamController<Message>.broadcast();
    return _messageStreamController!.stream;
  }

  Stream<int> get peerCountStream {
    _peerCountController ??= StreamController<int>.broadcast();
    return _peerCountController!.stream;
  }

  Stream<List<Map<String, dynamic>>> get discoveredDevicesStream {
    _discoveredDevicesController ??= StreamController<List<Map<String, dynamic>>>.broadcast();
    return _discoveredDevicesController!.stream;
  }

  int get connectedPeerCount => _connectedDevices.length;
  
  List<Map<String, dynamic>> get discoveredDevices => List.unmodifiable(_discoveredDevices);

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
        _discoveredDevices.clear();
        for (ScanResult result in results) {
          _discoveredDevices.add({
            'id': result.device.remoteId.toString(),
            'name': result.device.platformName.isNotEmpty 
                ? result.device.platformName 
                : 'Unknown Device',
            'rssi': result.rssi,
            'device': result.device,
          });
          _handleDiscoveredDevice(result.device);
        }
        // Notify listeners
        _discoveredDevicesController?.add(List.from(_discoveredDevices));
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
      
      // Subscribe to message characteristic for incoming messages
      await _subscribeToMessages(device);
      
      // Listen for disconnection
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDeviceDisconnected(device);
        }
      });
      
      _updatePeerCount();
      developer.log('📱 Connected to device: ${device.platformName} (Total: ${_connectedDevices.length})');
    } catch (e) {
      developer.log('❌ Connection failed: $e');
      _connectedDevices.remove(device);
      _updatePeerCount();
    }
  }

  // Handle device disconnection
  void _handleDeviceDisconnected(BluetoothDevice device) {
    if (_connectedDevices.remove(device)) {
      _updatePeerCount();
      developer.log('📴 Device disconnected: ${device.platformName} (Total: ${_connectedDevices.length})');
    }
  }

  // Subscribe to incoming messages from a device
  Future<void> _subscribeToMessages(BluetoothDevice device) async {
    try {
      // Discover services
      final services = await device.discoverServices();
      
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == messageCharacteristicUuid.toLowerCase()) {
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);
              
              characteristic.lastValueStream.listen((value) {
                _handleIncomingData(value);
              });
              
              developer.log('✅ Subscribed to messages from ${device.platformName}');
              return;
            }
          }
        }
      }
    } catch (e) {
      developer.log('⚠️ Failed to subscribe to messages: $e');
    }
  }

  // Handle incoming BLE data
  void _handleIncomingData(List<int> data) async {
    try {
      // Decrypt and decompress
      final encryptedData = Uint8List.fromList(data);
      final decrypted = await EncryptionService.decryptBinary(encryptedData);
      final decompressed = CompressionService.decompressBytes(decrypted);
      final jsonString = utf8.decode(decompressed);
      final messageJson = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final message = Message.fromJson(messageJson);
      
      // Check if already processed (prevent loops)
      if (_processedMessageHashes.contains(message.contentHash)) {
        developer.log('⏭️ Duplicate message, skipping: ${message.id}');
        return;
      }
      
      // Check hop count
      if (message.hopCount >= AppConstants.maxHopCount) {
        developer.log('⏭️ Max hop count reached, not relaying: ${message.id}');
        return;
      }
      
      // Mark as processed
      _processedMessageHashes.add(message.contentHash);
      
      // Emit to message stream
      _messageStreamController?.add(message);
      developer.log('📥 Received message via Bluetooth: ${message.id}');
      
      // Relay to other peers (mesh propagation)
      final relayedMessage = message.incrementHopCount();
      await _relayMessage(relayedMessage);
      
    } catch (e) {
      developer.log('❌ Error handling incoming data: $e');
    }
  }

  // Send message via Bluetooth mesh
  Future<bool> sendMessage(Message message) async {
    if (_connectedDevices.isEmpty) {
      developer.log('⚠️ No connected devices, message not sent via Bluetooth');
      return false;
    }

    try {
      // Mark as processed to avoid receiving our own message
      _processedMessageHashes.add(message.contentHash);
      
      // Prepare message data
      final messageJson = message.toJson();
      final jsonString = jsonEncode(messageJson);
      final compressed = CompressionService.compressText(jsonString);
      final encrypted = await EncryptionService.encryptBinary(compressed);
      
      // Send to all connected devices
      int successCount = 0;
      for (var device in _connectedDevices) {
        try {
          final sent = await _writeToDevice(device, encrypted);
          if (sent) successCount++;
        } catch (e) {
          developer.log('⚠️ Failed to send to ${device.platformName}: $e');
        }
      }
      
      developer.log('📤 Sent message to $successCount/${_connectedDevices.length} devices');
      return successCount > 0;
    } catch (e) {
      developer.log('❌ Send message error: $e');
      return false;
    }
  }

  // Write data to a specific device
  Future<bool> _writeToDevice(BluetoothDevice device, List<int> data) async {
    try {
      final services = await device.discoverServices();
      
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == messageCharacteristicUuid.toLowerCase()) {
              // Check if characteristic supports write
              if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
                await characteristic.write(data, withoutResponse: characteristic.properties.writeWithoutResponse);
                return true;
              }
            }
          }
        }
      }
      return false;
    } catch (e) {
      developer.log('❌ Write to device error: $e');
      return false;
    }
  }

  // Relay message to other peers (mesh propagation)
  Future<void> _relayMessage(Message message) async {
    if (_connectedDevices.isEmpty) return;
    
    try {
      final messageJson = message.toJson();
      final jsonString = jsonEncode(messageJson);
      final compressed = CompressionService.compressText(jsonString);
      final encrypted = await EncryptionService.encryptBinary(compressed);
      
      // Relay to all connected devices
      for (var device in _connectedDevices) {
        try {
          await _writeToDevice(device, encrypted);
        } catch (e) {
          developer.log('⚠️ Relay failed to ${device.platformName}: $e');
        }
      }
      
      developer.log('🔄 Relayed message (hop ${message.hopCount})');
    } catch (e) {
      developer.log('❌ Relay error: $e');
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

