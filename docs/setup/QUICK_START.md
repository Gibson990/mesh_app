# 🚀 Quick Start Guide - Mesh App

## 📱 Build & Run

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run on device
flutter run

# Build release APK
flutter build apk --release
```

---

## 🔑 Admin Login

**Default Credentials** (CHANGE THESE!):
- Username: `admin1`
- Password: `MeshSecure2024!`

**Login Steps**:
1. Open app → Settings
2. Tap "Admin Login"
3. Enter credentials
4. Tap "Login"

---

## 📡 Bluetooth Mesh Setup

**Requirements**:
- 2+ devices with Bluetooth
- Location permission (required for BLE scanning)
- Bluetooth enabled

**Steps**:
1. Enable Bluetooth on all devices
2. Grant all permissions when prompted
3. Open app on all devices
4. Devices will auto-discover and connect
5. Send messages - they'll propagate through mesh!

---

## 📤 Media Upload to Telegram

**Automatic Upload**:
- Images, videos, audio → Auto-upload to MO29 channel
- Works when internet available
- Queues when offline
- Uploads instantly when internet restored

**Channel**: MO29 (`@MO29` or `-1003219185632`)

---

## 🔐 Change Admin Password

**Generate Hash**:
```powershell
# Windows PowerShell
$password = "YourNewPassword"
$hash = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$hashBytes = $hash.ComputeHash($bytes)
[System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
```

**Update Code**:
Edit `lib/core/constants/app_constants.dart`:
```dart
static const Map<String, String> defaultAdminPasswordHashes = {
  'admin1': 'YOUR_NEW_HASH_HERE',
};
```

**Rebuild**:
```bash
flutter clean && flutter build apk --release
```

---

## 🐛 Troubleshooting

### Bluetooth Not Connecting
1. Restart Bluetooth
2. Grant Location permission
3. Restart app
4. Check logs: `flutter run --verbose`

### Media Not Uploading
1. Check internet connection
2. Verify Telegram bot token in `lib/config/telegram_config.dart`
3. Check logs for upload status

### Admin Login Failed
1. Verify username exists in `app_constants.dart`
2. Check password hash is correct
3. Try default credentials first

---

## 📊 Check Status

**View Logs**:
```bash
flutter run --verbose
```

**Key Log Messages**:
- `🔐 Generated encryption keys` - Security working
- `📱 Connected to device` - Bluetooth connected
- `📤 Sent message to X devices` - Mesh working
- `📥 Received message` - Mesh receiving
- `🌐 Internet ACTIVE` - Upload ready
- `✅ Uploaded to Telegram` - Upload success

---

## 📁 Important Files

- `lib/core/constants/app_constants.dart` - Admin credentials
- `lib/config/telegram_config.dart` - Telegram settings
- `SECURITY_AND_FIXES.md` - Full documentation
- `ADMIN_CREDENTIALS.md` - Password management

---

## ⚡ Quick Commands

```bash
# Clean build
flutter clean && flutter pub get && flutter run

# Check for issues
flutter analyze

# Build release
flutter build apk --release

# Install on device
flutter install

# View logs
adb logcat | grep -i mesh
```

---

## ✅ Pre-Deployment Checklist

- [ ] Change admin passwords
- [ ] Test on 2+ physical devices
- [ ] Test Bluetooth mesh
- [ ] Test media upload
- [ ] Verify Telegram integration
- [ ] Test offline mode
- [ ] Build release APK
- [ ] Test release APK on device

---

## 🎯 Features

✅ Bluetooth mesh networking
✅ End-to-end encryption
✅ Auto media upload to Telegram
✅ Admin verified posts
✅ Offline-first design
✅ Message compression
✅ Duplicate prevention
✅ Hop-based relay (max 10)

---

## 📞 Need Help?

1. Read `SECURITY_AND_FIXES.md`
2. Check `ADMIN_CREDENTIALS.md`
3. Review `FIXES_SUMMARY.md`
4. Run with verbose logs
5. Test on physical devices (not emulator for Bluetooth)
