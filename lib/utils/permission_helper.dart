import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request all required permissions
  static Future<bool> requestAllPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
    ];

    final statuses = await permissions.request();
    
    // Check if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }

  // Request Bluetooth permissions
  static Future<bool> requestBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check if Bluetooth permissions are granted
  static Future<bool> hasBluetoothPermissions() async {
    final bluetooth = await Permission.bluetooth.status;
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final location = await Permission.location.status;

    return bluetooth.isGranted &&
        bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        location.isGranted;
  }

  // Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

