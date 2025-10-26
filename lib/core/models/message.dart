import 'package:intl/intl.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
}

enum MessageTab {
  threads,
  media,
  updates,
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final MessageTab tab;
  final DateTime timestamp;
  final String? parentId; // For threaded replies
  final bool isVerified; // For higher-access user posts
  final String contentHash; // SHA-256 hash for duplicate detection
  final int hopCount; // For mesh relay tracking
  final String? location; // City name where message was sent from
  final bool uploadedToTelegram; // Track if media uploaded to Telegram
  final DateTime? telegramUploadTime; // When media was uploaded

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.tab,
    required this.timestamp,
    this.parentId,
    this.isVerified = false,
    required this.contentHash,
    this.hopCount = 0,
    this.location,
    this.uploadedToTelegram = false,
    this.telegramUploadTime,
  });

  // Convert to JSON for transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString(),
      'tab': tab.toString(),
      'timestamp': timestamp.toIso8601String(),
      'parentId': parentId,
      'isVerified': isVerified,
      'contentHash': contentHash,
      'hopCount': hopCount,
      'location': location,
      'uploadedToTelegram': uploadedToTelegram,
      'telegramUploadTime': telegramUploadTime?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      tab: MessageTab.values.firstWhere(
        (e) => e.toString() == json['tab'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      parentId: json['parentId'],
      isVerified: json['isVerified'] ?? false,
      contentHash: json['contentHash'],
      hopCount: json['hopCount'] ?? 0,
      location: json['location'],
      uploadedToTelegram: json['uploadedToTelegram'] ?? false,
      telegramUploadTime: json['telegramUploadTime'] != null 
          ? DateTime.parse(json['telegramUploadTime']) 
          : null,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.index,
      'tab': tab.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'parentId': parentId,
      'isVerified': isVerified ? 1 : 0,
      'contentHash': contentHash,
      'hopCount': hopCount,
      'location': location,
      'uploadedToTelegram': uploadedToTelegram ? 1 : 0,
      'telegramUploadTime': telegramUploadTime?.millisecondsSinceEpoch,
    };
  }

  // Create from database map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      content: map['content'],
      type: MessageType.values[map['type']],
      tab: MessageTab.values[map['tab']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      parentId: map['parentId'],
      isVerified: map['isVerified'] == 1,
      contentHash: map['contentHash'],
      hopCount: map['hopCount'] ?? 0,
      location: map['location'],
      uploadedToTelegram: (map['uploadedToTelegram'] ?? 0) == 1,
      telegramUploadTime: map['telegramUploadTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['telegramUploadTime'])
          : null,
    );
  }

  // Create a copy with updated hop count
  Message incrementHopCount() {
    return Message(
      id: id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      tab: tab,
      timestamp: timestamp,
      parentId: parentId,
      isVerified: isVerified,
      contentHash: contentHash,
      hopCount: hopCount + 1,
      location: location,
      uploadedToTelegram: uploadedToTelegram,
      telegramUploadTime: telegramUploadTime,
    );
  }

  // Create a copy with Telegram upload status
  Message markAsUploadedToTelegram() {
    return Message(
      id: id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      tab: tab,
      timestamp: timestamp,
      parentId: parentId,
      isVerified: isVerified,
      contentHash: contentHash,
      hopCount: hopCount,
      location: location,
      uploadedToTelegram: true,
      telegramUploadTime: DateTime.now(),
    );
  }

  // Check if this is a media message
  bool get isMedia => type == MessageType.image || 
                      type == MessageType.video || 
                      type == MessageType.audio;

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, y').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
