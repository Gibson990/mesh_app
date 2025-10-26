# Critical Gaps - Implementation Plan

## 🎯 Overview

These are the core features needed to make the mesh network actually work. Currently, the app can scan for Bluetooth devices but cannot transmit messages or files over BLE.

---

## 1. 🔴 CRITICAL: Actual BLE Message Transmission

### Current State:
- ✅ BLE scanning works
- ✅ Device discovery works
- ❌ No actual message transmission
- ❌ No GATT characteristics setup
- ❌ No data sending over BLE

### What's Needed:

#### A. GATT Service & Characteristics Setup
```dart
// Define custom GATT service for mesh messaging
class MeshGattService {
  static const String SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0";
  static const String MESSAGE_CHAR_UUID = "12345678-1234-5678-1234-56789abcdef1";
  static const String FILE_CHAR_UUID = "12345678-1234-5678-1234-56789abcdef2";
  static const String ACK_CHAR_UUID = "12345678-1234-5678-1234-56789abcdef3";
}
```

#### B. Message Serialization
```dart
// Convert Message to bytes for BLE transmission
class MessageSerializer {
  static Uint8List serialize(Message message) {
    // Convert message to JSON
    final json = message.toJson();
    final jsonString = jsonEncode(json);
    
    // Compress if needed
    final compressed = gzip.encode(utf8.encode(jsonString));
    
    return Uint8List.fromList(compressed);
  }
  
  static Message deserialize(Uint8List bytes) {
    // Decompress
    final decompressed = gzip.decode(bytes);
    final jsonString = utf8.decode(decompressed);
    
    // Parse JSON
    final json = jsonDecode(jsonString);
    return Message.fromJson(json);
  }
}
```

#### C. BLE Transmission Service
```dart
class BleTransmissionService {
  Future<bool> sendMessage(Message message, String deviceId) async {
    try {
      // 1. Connect to device
      await _connectToDevice(deviceId);
      
      // 2. Discover services
      final services = await device.discoverServices();
      
      // 3. Find our custom service
      final service = services.firstWhere(
        (s) => s.uuid == MeshGattService.SERVICE_UUID
      );
      
      // 4. Find message characteristic
      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid == MeshGattService.MESSAGE_CHAR_UUID
      );
      
      // 5. Serialize message
      final bytes = MessageSerializer.serialize(message);
      
      // 6. Send in chunks (BLE max ~512 bytes)
      await _sendInChunks(characteristic, bytes);
      
      // 7. Wait for ACK
      final ack = await _waitForAck();
      
      return ack;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }
}
```

### Implementation Steps:
1. ✅ Define GATT service UUIDs
2. ✅ Create MessageSerializer class
3. ✅ Implement BleTransmissionService
4. ✅ Add chunking for large messages
5. ✅ Implement ACK mechanism
6. ✅ Test with two devices

**Estimated Time:** 4-6 hours

---

## 2. 🔴 CRITICAL: File Chunking

### Current State:
- ✅ File paths stored in messages
- ❌ Files not transmitted
- ❌ No chunking mechanism
- ❌ No reassembly

### What's Needed:

#### A. File Chunker
```dart
class FileChunker {
  static const int CHUNK_SIZE = 512; // BLE MTU size
  
  static List<Uint8List> chunkFile(File file) {
    final bytes = file.readAsBytesSync();
    final chunks = <Uint8List>[];
    
    for (int i = 0; i < bytes.length; i += CHUNK_SIZE) {
      final end = (i + CHUNK_SIZE < bytes.length) 
          ? i + CHUNK_SIZE 
          : bytes.length;
      chunks.add(Uint8List.fromList(bytes.sublist(i, end)));
    }
    
    return chunks;
  }
  
  static File reassembleFile(List<Uint8List> chunks, String path) {
    final bytes = <int>[];
    for (final chunk in chunks) {
      bytes.addAll(chunk);
    }
    
    final file = File(path);
    file.writeAsBytesSync(bytes);
    return file;
  }
}
```

#### B. Chunk Metadata
```dart
class ChunkMetadata {
  final String fileId;
  final int chunkIndex;
  final int totalChunks;
  final String checksum; // MD5 or SHA256
  
  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'chunkIndex': chunkIndex,
    'totalChunks': totalChunks,
    'checksum': checksum,
  };
}
```

#### C. Chunk Transmission
```dart
class ChunkTransmitter {
  Future<bool> sendFile(File file, String deviceId) async {
    // 1. Chunk the file
    final chunks = FileChunker.chunkFile(file);
    final fileId = Uuid().v4();
    
    // 2. Send metadata first
    await _sendMetadata(fileId, chunks.length, deviceId);
    
    // 3. Send each chunk
    for (int i = 0; i < chunks.length; i++) {
      final metadata = ChunkMetadata(
        fileId: fileId,
        chunkIndex: i,
        totalChunks: chunks.length,
        checksum: _calculateChecksum(chunks[i]),
      );
      
      await _sendChunk(chunks[i], metadata, deviceId);
      
      // Wait for ACK
      final ack = await _waitForChunkAck(i);
      if (!ack) {
        // Retry
        await _sendChunk(chunks[i], metadata, deviceId);
      }
    }
    
    return true;
  }
}
```

### Implementation Steps:
1. ✅ Create FileChunker class
2. ✅ Implement chunk metadata
3. ✅ Add checksum verification
4. ✅ Implement chunk transmission
5. ✅ Add reassembly logic
6. ✅ Test with various file sizes

**Estimated Time:** 3-4 hours

---

## 3. 🟡 IMPORTANT: Media File Transmission

### Current State:
- ✅ Media files selected
- ✅ File paths stored
- ❌ Files not transmitted over BLE
- ❌ No progress tracking

### What's Needed:

#### A. Media Transmission Service
```dart
class MediaTransmissionService {
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;
  
  Future<bool> sendMediaFile(File file, MessageType type, String deviceId) async {
    try {
      // 1. Compress if needed
      final compressed = await _compressMedia(file, type);
      
      // 2. Chunk the file
      final chunks = FileChunker.chunkFile(compressed);
      
      // 3. Send with progress tracking
      for (int i = 0; i < chunks.length; i++) {
        await _sendChunk(chunks[i], i, chunks.length, deviceId);
        
        // Update progress
        final progress = (i + 1) / chunks.length;
        _progressController.add(progress);
      }
      
      return true;
    } catch (e) {
      print('Error sending media: $e');
      return false;
    }
  }
  
  Future<File> _compressMedia(File file, MessageType type) async {
    if (type == MessageType.image) {
      // Compress image
      final image = img.decodeImage(file.readAsBytesSync());
      final compressed = img.encodeJpg(image!, quality: 85);
      
      final tempFile = File('${file.path}_compressed.jpg');
      tempFile.writeAsBytesSync(compressed);
      return tempFile;
    }
    
    // For video/audio, return as-is (or implement compression)
    return file;
  }
}
```

#### B. Progress UI
```dart
// In message_card.dart
Widget _buildMediaProgress(double progress) {
  return Container(
    padding: EdgeInsets.all(8),
    child: Column(
      children: [
        LinearProgressIndicator(value: progress),
        SizedBox(height: 4),
        Text('${(progress * 100).toInt()}%'),
      ],
    ),
  );
}
```

### Implementation Steps:
1. ✅ Create MediaTransmissionService
2. ✅ Add image compression
3. ✅ Implement progress tracking
4. ✅ Add progress UI
5. ✅ Test with images, videos, audio

**Estimated Time:** 2-3 hours

---

## 4. 🟡 IMPORTANT: Multi-hop Relay

### Current State:
- ✅ Hop count tracked in messages
- ❌ No message forwarding
- ❌ No relay logic

### What's Needed:

#### A. Message Relay Service
```dart
class MessageRelayService {
  static const int MAX_HOPS = 5;
  final Set<String> _seenMessages = {}; // Prevent loops
  
  Future<void> relayMessage(Message message) async {
    // 1. Check if already seen
    if (_seenMessages.contains(message.id)) {
      return; // Already relayed
    }
    
    // 2. Check hop count
    if (message.hopCount >= MAX_HOPS) {
      return; // Max hops reached
    }
    
    // 3. Mark as seen
    _seenMessages.add(message.id);
    
    // 4. Increment hop count
    final relayedMessage = Message(
      id: message.id,
      senderId: message.senderId,
      senderName: message.senderName,
      content: message.content,
      type: message.type,
      tab: message.tab,
      timestamp: message.timestamp,
      parentId: message.parentId,
      isVerified: message.isVerified,
      contentHash: message.contentHash,
      hopCount: message.hopCount + 1,
      location: message.location,
    );
    
    // 5. Send to all connected peers
    final peers = await _getConnectedPeers();
    for (final peer in peers) {
      await _bleTransmissionService.sendMessage(relayedMessage, peer.id);
    }
  }
}
```

#### B. Flood Prevention
```dart
class FloodPrevention {
  final Map<String, DateTime> _messageTimestamps = {};
  static const Duration DUPLICATE_WINDOW = Duration(minutes: 5);
  
  bool shouldRelay(Message message) {
    final lastSeen = _messageTimestamps[message.id];
    
    if (lastSeen != null) {
      final elapsed = DateTime.now().difference(lastSeen);
      if (elapsed < DUPLICATE_WINDOW) {
        return false; // Too recent, don't relay
      }
    }
    
    _messageTimestamps[message.id] = DateTime.now();
    return true;
  }
}
```

### Implementation Steps:
1. ✅ Create MessageRelayService
2. ✅ Implement flood prevention
3. ✅ Add seen message tracking
4. ✅ Test multi-hop scenarios

**Estimated Time:** 2-3 hours

---

## 5. 🟡 IMPORTANT: Mesh Routing

### Current State:
- ❌ No routing algorithm
- ❌ No path discovery
- ❌ No route optimization

### What's Needed:

#### A. Simple Flooding (Phase 1)
```dart
// Simplest approach: broadcast to all peers
class FloodingRouter {
  Future<void> route(Message message) async {
    final peers = await _getConnectedPeers();
    
    for (final peer in peers) {
      await _sendToPeer(message, peer);
    }
  }
}
```

#### B. Distance Vector Routing (Phase 2)
```dart
class DistanceVectorRouter {
  final Map<String, int> _distances = {}; // deviceId -> hop count
  final Map<String, String> _nextHops = {}; // destination -> next hop
  
  Future<void> updateRoutingTable() async {
    // Exchange routing info with neighbors
    final neighbors = await _getConnectedPeers();
    
    for (final neighbor in neighbors) {
      final theirTable = await _requestRoutingTable(neighbor);
      _mergeRoutingTables(theirTable);
    }
  }
  
  Future<void> route(Message message, String destination) async {
    final nextHop = _nextHops[destination];
    
    if (nextHop != null) {
      await _sendToPeer(message, nextHop);
    } else {
      // Fallback to flooding
      await _floodingRouter.route(message);
    }
  }
}
```

### Implementation Steps:
1. ✅ Implement flooding router (simple)
2. ✅ Add routing table
3. ✅ Implement distance vector algorithm
4. ✅ Add route optimization
5. ✅ Test with multiple hops

**Estimated Time:** 4-5 hours

---

## 📊 Implementation Priority

### Phase 1: Core Transmission (Week 1)
1. **BLE Message Transmission** (Day 1-2)
   - GATT setup
   - Message serialization
   - Basic send/receive

2. **File Chunking** (Day 3-4)
   - Chunk algorithm
   - Reassembly
   - Checksum verification

3. **Testing** (Day 5)
   - Two device testing
   - Message transmission
   - File transmission

### Phase 2: Media & Relay (Week 2)
4. **Media File Transmission** (Day 1-2)
   - Image compression
   - Progress tracking
   - UI updates

5. **Multi-hop Relay** (Day 3-4)
   - Relay logic
   - Flood prevention
   - Testing

### Phase 3: Routing (Week 3)
6. **Mesh Routing** (Day 1-3)
   - Flooding router
   - Distance vector
   - Optimization

7. **Integration & Testing** (Day 4-5)
   - Full mesh testing
   - Performance tuning
   - Bug fixes

---

## 🧪 Testing Strategy

### Unit Tests:
- Message serialization/deserialization
- File chunking/reassembly
- Checksum verification
- Routing algorithms

### Integration Tests:
- Two device message exchange
- File transmission
- Multi-hop relay
- Network topology changes

### Field Tests:
- Real-world mesh network
- Multiple devices (3+)
- Various distances
- Interference handling

---

## 📝 Dependencies Needed

```yaml
# pubspec.yaml
dependencies:
  # Already have flutter_blue_plus
  
  # For compression
  archive: ^3.6.1
  
  # For checksums
  crypto: ^3.0.3
  
  # For image compression
  image: ^4.3.0
  
  # For UUID generation
  uuid: ^4.5.1
```

---

## 🎯 Success Criteria

### Minimum Viable:
- ✅ Send text messages over BLE
- ✅ Receive messages from peers
- ✅ Send small files (<1MB)
- ✅ Basic relay (1 hop)

### Full Featured:
- ✅ Send large files (>10MB)
- ✅ Multi-hop relay (5 hops)
- ✅ Intelligent routing
- ✅ Progress tracking
- ✅ Error recovery

---

**Status:** Ready to implement
**Next Step:** Fix image display issue, then start Phase 1
**Estimated Total Time:** 2-3 weeks for full implementation
