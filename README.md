# 🌐 Mesh - Decentralized Communication App

[![Flutter](https://img.shields.io/badge/Flutter-3.3.1+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev/)

**A decentralized, protest-proof chat application with Bluetooth mesh networking and external platform integration.**

Mesh enables secure, peer-to-peer communication that works even when traditional internet infrastructure is compromised. Built with Flutter, it combines Bluetooth Low Energy (BLE) mesh networking with automatic synchronization to Telegram channels.

## 🚀 Features

### 📱 **Core Messaging**
- **Text Messages** - Send encrypted text messages across the mesh network
- **Voice Notes** - Record and share audio messages (15s max)
- **Image Sharing** - Capture or select photos with automatic compression
- **Video Messages** - Record and share short videos (15s max)
- **Threading** - Reply to messages with visual thread indicators
- **Captions** - Add captions to all media types

### 🔗 **Bluetooth Mesh Network**
- **Device Discovery** - Automatic scanning for nearby mesh-enabled devices
- **Multi-hop Relay** - Messages propagate through multiple devices
- **Encryption** - End-to-end encryption for all mesh communications
- **Offline Operation** - Works without internet connectivity
- **Auto-reconnection** - Handles connection drops gracefully

### 🌐 **External Platform Integration**
- **Telegram Bot** - Automatic upload of all media to configured Telegram channel
- **Offline Queue** - Messages queued when offline, sent when connection restored
- **Retry Logic** - Automatic retry with exponential backoff for failed uploads

### 🔒 **Security & Privacy**
- **End-to-End Encryption** - All messages encrypted using AES-256
- **Content Hashing** - Duplicate message prevention
- **Secure Storage** - Credentials stored using Flutter Secure Storage
- **Permission Management** - Granular permission requests and handling

### 🎨 **User Experience**
- **Modern UI** - Clean, intuitive interface with dark/light theme support
- **Real-time Updates** - Live peer count and connection status
- **Loading States** - Visual feedback for all operations
- **Error Handling** - Comprehensive error messages and recovery
- **Haptic Feedback** - Tactile responses for better UX

## 📋 **Use Cases**

### 🏛️ **Protest & Activism**
- Coordinate activities when cellular networks are jammed
- Share real-time updates and media from events
- Maintain communication during internet shutdowns

### 🚨 **Emergency Situations**
- Disaster response coordination
- Search and rescue operations
- Community emergency networks

### 🏕️ **Remote Areas**
- Communication in areas with poor cellular coverage
- Hiking and camping groups
- Rural community networks

### 🔐 **Privacy-Conscious Users**
- Decentralized communication without central servers
- Reduced digital footprint
- Censorship-resistant messaging

## 🛠️ **Technical Architecture**

### **Frontend**
- **Flutter 3.3.1+** - Cross-platform mobile development
- **Provider** - State management
- **Material Design 3** - Modern UI components

### **Networking**
- **Flutter Blue Plus** - Bluetooth Low Energy communication
- **HTTP** - External platform integration

### **Storage**
- **SQLite** - Local message persistence
- **Shared Preferences** - App settings
- **Flutter Secure Storage** - Credential management

### **Media Processing**
- **Image Compression** - Automatic optimization for transmission
- **Video Compression** - Size reduction for mesh transmission
- **Audio Recording** - High-quality voice note capture

### **Security**
- **AES-256 Encryption** - Message encryption
- **SHA-256 Hashing** - Content integrity verification

## 📦 **Installation**

### **Prerequisites**
- Flutter SDK 3.3.1 or higher
- Android Studio / VS Code
- Android device with Bluetooth LE support
- Git

### **Clone Repository**
```bash
git clone https://github.com/Gibson990/mesh_app.git
cd mesh_app
```

### **Install Dependencies**
```bash
flutter pub get
```

### **Configure External Platforms**

#### **Telegram Setup (Currently Active)**
**Current Configuration**: The app is pre-configured to upload to the official MO29 channel.

**For Production Use:**
- **Official Channel**: [https://t.me/theMO29](https://t.me/theMO29)
- **Bot**: @theMO29_bot (already configured)
- **Auto-upload**: All media with timestamps and captions
- **Access**: Public channel for transparency and monitoring

**For Custom Setup:**
1. Create a bot via [@BotFather](https://t.me/BotFather)
2. Get your bot token
3. Create a channel and add your bot as admin
4. Get the channel ID
5. Update `lib/config/telegram_config.dart`:
```dart
static String botToken = 'YOUR_BOT_TOKEN_HERE';
static String channelId = 'YOUR_CHANNEL_ID_HERE';
```

### **Build & Run**
```bash
# Debug build
flutter run

# Release build
flutter build apk --release
```

## 🎯 **Usage & User Flow**

### **👤 Access Levels**

#### **Regular Users (Anonymous)**
- Send and receive messages via Bluetooth mesh
- Share media (images, videos, audio) with automatic compression
- View all content in threads and media tabs
- Participate in mesh network communication
- **No internet required** for basic functionality

#### **Admin/Coordinator Users** 
- All regular user capabilities
- **Verified badge** on messages for authenticity
- **Internet access responsibility** for external platform sync
- **Media consistency management** - ensures all collected media from threads is properly compressed and uploaded
- **Automatic upload coordination** to Telegram channel for permanent storage
- **Network reliability** - provides backup and synchronization when internet is available

**Why Admin Access is Needed:**
Admins serve as **bridge nodes** between the offline mesh network and external platforms. When internet connectivity is available, admins automatically compress and upload all collected media from the mesh network to external channels (currently Telegram), ensuring nothing is lost and providing a permanent backup of important communications during protests, emergencies, or remote operations.

### **🔄 Complete User Flow**

#### **1. First Launch & Setup**
```
📱 Install App
    ↓
🔐 Grant Permissions (Bluetooth, Location, Camera, Microphone)
    ↓
📡 Automatic Bluetooth scanning starts
    ↓
🌐 Optional: Admin configures Telegram integration
    ↓
✅ Ready to communicate
```

#### **2. Regular User Journey**
```
💬 Open App
    ↓
📊 See peer count (nearby devices)
    ↓
📝 Send Message/Media
    ↓
📡 Message propagates through mesh
    ↓
📱 Other users receive instantly
    ↓
🔄 Continues offline indefinitely
```

#### **3. Admin User Journey (with Internet)**
```
💬 Receive mesh messages
    ↓
📸 Collect media from all threads
    ↓
🗜️ Automatic compression (images <1MB, videos <5MB)
    ↓
📤 Auto-upload to Telegram channel
    ↓
✅ Permanent backup created
    ↓
🔄 Sync status shared with mesh
```

#### **4. Media Sharing Flow**
```
📷 Capture/Select Media
    ↓
🗜️ Automatic compression
    ↓
💬 Add caption (optional)
    ↓
📡 Send via Bluetooth mesh
    ↓
📱 Appears in both Threads & Media tabs
    ↓
🌐 Admin auto-uploads to Telegram (when online)
    ↓
🔗 Permanent link available at: https://t.me/theMO29
```

### **🌐 Current External Integration**

#### **✅ Telegram Integration (Active)**
- **Channel**: [MO29 Official](https://t.me/theMO29)
- **Auto-upload**: All media with captions and timestamps
- **Compression**: Optimized for Telegram limits
- **Backup**: Permanent storage of mesh communications
- **Access**: Public channel for transparency

### **📱 Daily Usage Scenarios**

#### **Protest/Event Coordination**
1. **Participants** join mesh network automatically
2. **Share real-time updates** via text and media
3. **Coordinate movements** through threaded conversations
4. **Admin uploads** everything to Telegram for permanent record
5. **External supporters** follow via https://t.me/theMO29

#### **Emergency Response**
1. **First responders** connect via Bluetooth mesh
2. **Share situation updates** and location info
3. **Coordinate resources** through secure messaging
4. **Document evidence** with automatic media backup
5. **Command center** monitors via Telegram channel

#### **Remote Area Communication**
1. **Team members** stay connected without cell towers
2. **Share location updates** and safety check-ins
3. **Document findings** with photos and videos
4. **Sync with base** when internet becomes available
5. **Maintain records** through automated uploads

### **🔧 Network Behavior**

#### **Offline Mode (Default)**
- Pure Bluetooth mesh communication
- No internet required
- Messages propagate peer-to-peer
- Media shared directly between devices
- Perfect for censored or jammed networks

#### **Online Mode (Admin with Internet)**
- All offline functionality continues
- **Plus**: Automatic backup to Telegram
- **Plus**: External monitoring capability
- **Plus**: Permanent record creation
- **Plus**: Wider audience reach via https://t.me/theMO29

### **🎯 Getting Started**

#### **For Regular Users**
1. Install app and grant permissions
2. Start communicating immediately
3. Messages work offline via Bluetooth mesh
4. Media automatically compressed and shared

#### **For Admins/Coordinators**
1. Complete regular user setup
2. Configure Telegram bot credentials
3. Ensure periodic internet access
4. Monitor https://t.me/theMO29 for uploads
5. Coordinate between mesh and external platforms

## 🔧 **Configuration**

### **App Settings**
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const Duration bluetoothScanDuration = Duration(seconds: 10);
  static const int maxMeshNodes = 8;
  static const int maxHopCount = 5;
  static const int maxMessageLength = 1000;
}
```

### **Media Limits**
- **Images**: Auto-compressed to max 1MB
- **Videos**: 15 seconds max, compressed to 5MB
- **Audio**: 15 seconds max, 500KB limit

### **Security Settings**
- All messages encrypted with AES-256
- Keys rotated every 24 hours
- Content hashed to prevent duplicates

## 🧪 **Testing**

### **Unit Tests**
```bash
flutter test
```

### **Manual Testing Checklist**
- [ ] Bluetooth device discovery
- [ ] Message sending/receiving
- [ ] Media upload/download
- [ ] Telegram integration
- [ ] Offline functionality
- [ ] Permission handling
- [ ] Error recovery

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](docs/development/CONTRIBUTING.md) for details.

### **Development Setup**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass: `flutter test`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### **Code Style**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain test coverage above 80%

## 📊 **Project Status**

### **Completed Features** ✅
- Core messaging (text, voice, images, videos)
- Bluetooth device discovery and connection
- Message threading and replies with visual indicators
- Media compression and optimization (images <1MB, videos <5MB)
- **Telegram integration with MO29 channel** ([https://t.me/theMO29](https://t.me/theMO29))
- Admin/Coordinator access levels with verified badges
- Automatic media upload and backup system
- Local storage and persistence
- Permission management and error handling
- Professional project organization and documentation

### **In Progress** 🚧
- Actual Bluetooth mesh message transmission (BLE communication layer)
- File chunking for large media over BLE network
- Battery optimization for continuous scanning
- Advanced encryption key management

### **Planned Features** 📋
- Group chat functionality with admin moderation
- Message search and filtering capabilities
- Export/backup conversations to external storage
- Advanced mesh routing algorithms for better propagation
- Cross-platform desktop support (Windows, macOS, Linux)
- Web interface for network monitoring and administration

## 🐛 **Known Issues**

- Bluetooth mesh transmission not fully implemented
- Large file transmission over BLE needs optimization
- Battery optimization needed for continuous scanning
- iOS support requires additional testing

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Bluetooth LE community for protocols and best practices
- Open source contributors and testers
- Privacy and security researchers

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/Gibson990/mesh_app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Gibson990/mesh_app/discussions)
- **Telegram Channel**: [https://t.me/theMO29](https://t.me/theMO29)

## 🌟 **Star History**

[![Star History Chart](https://api.star-history.com/svg?repos=Gibson990/mesh_app&type=Date)](https://star-history.com/#Gibson990/mesh_app&Date)

---

**Built with ❤️ for a more connected and decentralized world.**
