import 'dart:developer' as developer;
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/core/models/user.dart';
import 'package:mesh_app/core/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mesh.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        content TEXT NOT NULL,
        type INTEGER NOT NULL,
        tab INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        parentId TEXT,
        isVerified INTEGER NOT NULL,
        contentHash TEXT NOT NULL,
        hopCount INTEGER NOT NULL,
        location TEXT
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        isHigherAccess INTEGER NOT NULL,
        reputationScore INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db
        .execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_messages_tab ON messages(tab)');
    await db.execute('CREATE INDEX idx_messages_hash ON messages(contentHash)');
  }

  // Save message
  Future<bool> saveMessage(Message message) async {
    try {
      final db = await database;

      // Check for duplicate
      final existing = await db.query(
        'messages',
        where: 'contentHash = ?',
        whereArgs: [message.contentHash],
      );

      if (existing.isNotEmpty) {
        developer.log('Duplicate message detected, not saving');
        return false;
      }

      await db.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Clean up old messages if limit exceeded
      await _cleanupOldMessages();

      return true;
    } catch (e) {
      developer.log('Save message error: $e');
      return false;
    }
  }

  // Get messages by tab
  Future<List<Message>> getMessagesByTab(MessageTab tab) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'tab = ?',
        whereArgs: [tab.index],
        orderBy: 'timestamp DESC',
        limit: AppConstants.maxStoredMessages,
      );

      return maps.map((map) => Message.fromMap(map)).toList();
    } catch (e) {
      developer.log('Get messages error: $e');
      return [];
    }
  }

  // Get all messages
  Future<List<Message>> getAllMessages() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        orderBy: 'timestamp DESC',
        limit: AppConstants.maxStoredMessages,
      );

      return maps.map((map) => Message.fromMap(map)).toList();
    } catch (e) {
      developer.log('Get all messages error: $e');
      return [];
    }
  }

  // Search messages
  Future<List<Message>> searchMessages(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'content LIKE ? OR senderName LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'timestamp DESC',
      );

      return maps.map((map) => Message.fromMap(map)).toList();
    } catch (e) {
      developer.log('Search messages error: $e');
      return [];
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final db = await database;
      await db.delete(
        'messages',
        where: 'id = ?',
        whereArgs: [messageId],
      );
      return true;
    } catch (e) {
      developer.log('Delete message error: $e');
      return false;
    }
  }

  // Clean up old messages
  Future<void> _cleanupOldMessages() async {
    try {
      final db = await database;

      // Count total messages
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM messages'),
      );

      if (count != null && count > AppConstants.maxStoredMessages) {
        // Delete oldest messages
        final toDelete = count - AppConstants.maxStoredMessages;
        await db.rawDelete('''
          DELETE FROM messages 
          WHERE id IN (
            SELECT id FROM messages 
            ORDER BY timestamp ASC 
            LIMIT ?
          )
        ''', [toDelete]);
      }

      // Delete messages older than retention period
      final cutoffTime = DateTime.now()
          .subtract(AppConstants.messageRetentionPeriod)
          .millisecondsSinceEpoch;

      await db.delete(
        'messages',
        where: 'timestamp < ?',
        whereArgs: [cutoffTime],
      );
    } catch (e) {
      developer.log('Cleanup error: $e');
    }
  }

  // Save user
  Future<bool> saveUser(User user) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      developer.log('Save user error: $e');
      return false;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      developer.log('Get user error: $e');
      return null;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('messages');
      await db.delete('users');
    } catch (e) {
      developer.log('Clear data error: $e');
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
