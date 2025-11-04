# Admin Credentials - Mesh App

## 🔑 DEFAULT ADMIN ACCOUNTS

### Current Credentials (CHANGE BEFORE PRODUCTION!)

| Username | Password | Status |
|----------|----------|--------|
| admin1 | MeshSecure2024! | Active |
| admin2 | MeshSecure2024! | Active |
| admin3 | MeshSecure2024! | Active |

---

## 🔐 How to Change Admin Passwords

### Step 1: Generate SHA-256 Hash
Use one of these methods:

**Online Tool:**
- Visit: https://emn178.github.io/online-tools/sha256.html
- Enter your new password
- Copy the hash

**Command Line (Linux/Mac):**
```bash
echo -n "YourNewPassword" | sha256sum
```

**Command Line (Windows PowerShell):**
```powershell
$password = "YourNewPassword"
$hash = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$hashBytes = $hash.ComputeHash($bytes)
[System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
```

### Step 2: Update Code
Edit `lib/core/constants/app_constants.dart`:

```dart
static const Map<String, String> defaultAdminPasswordHashes = {
  'admin1': 'YOUR_NEW_HASH_HERE',  // Replace with your generated hash
  'admin2': 'YOUR_NEW_HASH_HERE',
  'admin3': 'YOUR_NEW_HASH_HERE',
};
```

### Step 3: Rebuild App
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 👥 Adding More Admins

You can add up to 30 admin accounts:

```dart
static const Map<String, String> defaultAdminPasswordHashes = {
  'admin1': 'hash1',
  'admin2': 'hash2',
  'admin3': 'hash3',
  'admin4': 'hash4',  // Add new admins here
  'admin5': 'hash5',
  // ... up to 30 total
};
```

---

## 🛡️ Security Best Practices

### DO:
✅ Change default passwords immediately
✅ Use strong passwords (12+ characters, mixed case, numbers, symbols)
✅ Use unique passwords for each admin
✅ Keep this file secure (add to .gitignore)
✅ Rotate passwords regularly

### DON'T:
❌ Share passwords in plain text
❌ Use simple passwords (e.g., "admin123")
❌ Reuse passwords from other services
❌ Commit passwords to version control
❌ Share admin credentials publicly

---

## 🔓 Admin Login Process

### In-App Login:
1. Open app
2. Go to Settings
3. Tap "Admin Login"
4. Enter username (e.g., "admin1")
5. Enter password
6. Tap "Login"

### What Admins Can Do:
- ✅ Post to Updates tab (verified badge)
- ✅ Messages marked as "Verified"
- ✅ Higher reputation score (100)
- ✅ Bypass some spam filters (future feature)

---

## 🚨 If Credentials Are Compromised

1. **Immediately change passwords**:
   - Generate new hashes
   - Update `app_constants.dart`
   - Rebuild and redeploy app

2. **Revoke compromised accounts**:
   - Remove from `defaultAdminPasswordHashes` map
   - Rebuild app

3. **Monitor for suspicious activity**:
   - Check Telegram channel for unauthorized posts
   - Review app logs

---

## 📝 Password Requirements

**Minimum Requirements:**
- Length: 8+ characters
- Complexity: Mix of uppercase, lowercase, numbers

**Recommended:**
- Length: 16+ characters
- Include special characters (!@#$%^&*)
- Use a password manager
- Enable 2FA (future feature)

---

## 🔄 Password Recovery

**IMPORTANT**: There is NO password recovery system!

If you forget an admin password:
1. You must regenerate the hash with a new password
2. Update the code
3. Rebuild the app

**Keep a secure backup of your passwords!**

---

## 📞 Emergency Access

If all admin credentials are lost:
1. Edit `app_constants.dart`
2. Add a new admin with known password hash
3. Rebuild app from source
4. Reinstall on all devices

---

## 🔐 Current Password Hashes (for reference)

**Default Password**: `MeshSecure2024!`
**SHA-256 Hash**: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

**Note**: This is a placeholder hash. The actual hash for "MeshSecure2024!" is different. 
You MUST generate the correct hash and update the code before deployment.

---

## 📊 Admin Activity Log

Keep track of admin accounts:

| Date | Action | Admin | Notes |
|------|--------|-------|-------|
| 2024-10-26 | Created | admin1, admin2, admin3 | Initial setup |
| | | | |
| | | | |

---

## ⚠️ SECURITY WARNING

**DO NOT COMMIT THIS FILE TO PUBLIC REPOSITORIES!**

Add to `.gitignore`:
```
ADMIN_CREDENTIALS.md
*.credentials
*.secrets
```
