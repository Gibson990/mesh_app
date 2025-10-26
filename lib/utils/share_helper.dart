import 'dart:developer' as developer;
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  // Share text content
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      developer.log('Error sharing text: $e');
    }
  }

  // Share message content
  static Future<void> shareMessage({
    required String content,
    required String senderName,
    required String timestamp,
    String? location,
  }) async {
    try {
      String shareText = content;

      if (location != null) {
        shareText += '\n\n— $senderName from $location';
      } else {
        shareText += '\n\n— $senderName';
      }

      shareText += '\n$timestamp';

      await Share.share(
        shareText,
        subject: 'Message from $senderName',
      );
    } catch (e) {
      developer.log('Error sharing message: $e');
    }
  }

  // Share media with caption
  static Future<void> shareMedia({
    required String type,
    required String senderName,
    String? caption,
    String? location,
  }) async {
    try {
      String shareText = '';

      if (caption != null && caption.isNotEmpty) {
        shareText = caption;
      }

      if (location != null) {
        shareText += '\n\n— $senderName from $location';
      } else {
        shareText += '\n\n— $senderName';
      }

      await Share.share(
        shareText,
        subject: '$type from $senderName',
      );
    } catch (e) {
      developer.log('Error sharing media: $e');
    }
  }

  // Share app information
  static Future<void> shareApp() async {
    try {
      const shareText = '''
Check out Mesh - a decentralized, protest-proof chat app!

🔗 Download: [App Store/Play Store link]
📱 Features:
• Bluetooth mesh networking
• End-to-end encryption
• Offline communication
• Anonymous messaging

#MeshApp #Decentralized #Privacy
      ''';

      await Share.share(
        shareText,
        subject: 'Mesh - Decentralized Chat App',
      );
    } catch (e) {
      developer.log('Error sharing app: $e');
    }
  }
}
