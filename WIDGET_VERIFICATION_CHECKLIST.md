# Widget Verification Checklist - Threads Tab

## 🎯 Purpose
Verify all widgets in the threads tab are displaying correctly and functioning as expected.

## 📋 Visual Verification Checklist

### 1. Empty State Widget ✓
**When:** No messages in threads tab
**Should Show:**
- [ ] Large forum icon (64px)
- [ ] "No messages yet" title
- [ ] "Start a conversation with your peers" subtitle
- [ ] Debug info showing "_messages.length = 0"

**Debug Log:**
```
📭 [ThreadsTab] Showing empty state
```

### 2. Connection Banner Widget ✓
**Location:** Top of threads tab
**Should Show:**
- [ ] Blue/accent colored container
- [ ] Bluetooth connected icon
- [ ] "Connected • 12 peers" text
- [ ] Rounded corners with border

### 3. Message Card Widgets
**When:** Messages exist in threads tab
**For Each Message Should Show:**

#### Text Messages
- [ ] Sender name (if not own message)
- [ ] Message content
- [ ] Timestamp
- [ ] Verified badge (if coordinator)
- [ ] Avatar (if thread start)
- [ ] Reply button
- [ ] Share button

#### Voice Note Messages
- [ ] Gradient background (accent color)
- [ ] Microphone icon
- [ ] Play button (animated)
- [ ] Progress bar
- [ ] Duration display
- [ ] Sender name
- [ ] Timestamp

#### Image Messages
- [ ] Image preview/thumbnail
- [ ] Rounded corners
- [ ] Gradient background
- [ ] Photo badge (📷)
- [ ] Caption (if provided)
- [ ] Sender name
- [ ] Timestamp

#### Video Messages
- [ ] Video thumbnail
- [ ] Dark gradient background
- [ ] Large play button (centered)
- [ ] Duration badge with video icon
- [ ] Caption (if provided)
- [ ] Sender name
- [ ] Timestamp

### 4. Reply Indicator Widget
**When:** Message has parent (is a reply)
**Should Show:**
- [ ] Light accent background
- [ ] Blue left border
- [ ] Parent sender name
- [ ] Parent content preview (truncated)
- [ ] Appropriate icon (📷 for images, 🎥 for videos, 🎵 for audio)

### 5. Reply Input Indicator Widget
**When:** User taps "Reply" on a message
**Should Show:**
- [ ] Container above message input
- [ ] "Replying to [sender name]" text
- [ ] Message preview
- [ ] Close button (X)
- [ ] Accent color styling

### 6. Message Input Widget ✓
**Location:** Bottom of screen
**Should Show:**
- [ ] Text input field with hint "Type a message..."
- [ ] Attachment button (paperclip icon)
- [ ] Voice note button (microphone icon)
- [ ] Send button (paper plane icon)
- [ ] Proper spacing and padding
- [ ] Disabled state when loading

### 7. Voice Note Recorder Modal
**When:** User taps microphone button
**Should Show:**
- [ ] Bottom sheet modal
- [ ] "Record Voice Note" title
- [ ] Large microphone icon (100px)
- [ ] Pulsing animation when recording
- [ ] Timer display (00:00)
- [ ] Remaining time countdown
- [ ] Cancel button
- [ ] Start/Stop button (changes based on state)

### 8. Attachment Options Modal
**When:** User taps attachment button
**Should Show:**
- [ ] Bottom sheet modal
- [ ] "Add Attachment" title
- [ ] Four options:
  - [ ] 📷 Pick Image from Gallery
  - [ ] 🎥 Pick Video from Gallery
  - [ ] 🎬 Record Video
  - [ ] 🎵 Pick Audio File
- [ ] Each option with icon and label
- [ ] Proper spacing between options

## 🔍 Functional Verification

### Message Display
- [ ] Messages appear immediately after sending
- [ ] Messages persist after app restart
- [ ] Messages scroll to bottom after send
- [ ] Multiple messages display correctly
- [ ] Own messages align right
- [ ] Other messages align left

### Reply Functionality
- [ ] Tapping "Reply" shows reply indicator
- [ ] Reply indicator shows correct parent info
- [ ] Sending reply creates proper parent-child relationship
- [ ] Reply shows parent preview in message card
- [ ] Closing reply indicator works

### Share Functionality
- [ ] Tapping "Share" captures screenshot
- [ ] Screenshot includes parent message if replying
- [ ] Share intent opens (when implemented)

### Voice Note Recording
- [ ] Modal opens on mic button tap
- [ ] Recording starts on "Start Recording"
- [ ] Timer counts up during recording
- [ ] Pulsing animation plays during recording
- [ ] Recording stops at 60 seconds
- [ ] Stop button saves and sends recording
- [ ] Cancel button discards recording

### Media Attachment
- [ ] Attachment modal opens on paperclip tap
- [ ] Image picker opens on "Pick Image"
- [ ] Video picker opens on "Pick Video"
- [ ] Camera opens on "Record Video"
- [ ] Audio picker opens on "Pick Audio"
- [ ] Selected media sends successfully
- [ ] Media message appears in threads

## 📊 Debug Log Verification

### Expected Log Sequence for Message Send:

```
📤 [ThreadsTab] Sending message: Hello
📤 Sending message: [uuid] - MessageType.text - MessageTab.threads
💾 Message saved to storage: true
📝 Added to local list. Total messages: 1
📡 Emitted to stream. Listeners: true
📶 Sent via Bluetooth
📴 Offline - skipping external relay
✅ Message sent successfully
📬 [ThreadsTab] Send result: true
🔄 [ThreadsTab] Forcing UI refresh
📊 [ThreadsTab] Got 1 messages after send
✅ [ThreadsTab] UI refreshed with 1 messages
🏗️ [ThreadsTab] Building UI with 1 messages
🎨 [ThreadsTab] Building message card 0 of 1
📨 [ThreadsTab] Message: MessageType.text - Hello...
📡 [ThreadsTab] Received 1 messages from stream
📝 [ThreadsTab] Filtered to 1 thread messages
✅ [ThreadsTab] UI updated with 1 messages
🏗️ [ThreadsTab] Building UI with 1 messages
🎨 [ThreadsTab] Building message card 0 of 1
📨 [ThreadsTab] Message: MessageType.text - Hello...
```

### Expected Log for Empty State:

```
🏗️ [ThreadsTab] Building UI with 0 messages
📭 [ThreadsTab] Showing empty state
```

### Expected Log for Voice Note:

```
📤 [ThreadsTab] Sending media: MessageType.audio - /path/to/audio.m4a
📬 [ThreadsTab] Media send result: true
🔄 [ThreadsTab] Forcing UI refresh after media send
📊 [ThreadsTab] Got 1 messages after media send
✅ [ThreadsTab] UI refreshed with 1 messages
```

## 🐛 Common Issues & Solutions

### Issue: Empty state shows but messages exist
**Check:**
- [ ] `_messages.length` in debug indicator
- [ ] Console logs show messages being added
- [ ] `setState()` is being called
- [ ] Widget is mounted

**Solution:**
```dart
// Force rebuild
setState(() {
  _messages.clear();
  _messages.addAll(_messageControllerService.getMessagesByTab(MessageTab.threads));
});
```

### Issue: Messages sent but widgets don't appear
**Check:**
- [ ] Build method is being called (🏗️ log)
- [ ] ItemBuilder is being called (🎨 log)
- [ ] Message count is correct
- [ ] ListView has proper constraints

**Solution:**
- Check if `Expanded` widget wraps ListView
- Verify `itemCount` matches `_messages.length`
- Check for layout errors in console

### Issue: Voice note modal doesn't open
**Check:**
- [ ] Microphone button is visible
- [ ] Button has proper onPressed handler
- [ ] No errors in console

**Solution:**
```dart
// Verify button code
IconButton(
  icon: const Icon(Icons.mic),
  onPressed: _showVoiceNoteRecorder,
)
```

### Issue: Media widgets show file path instead of preview
**Status:** ⚠️ EXPECTED - Media display not yet implemented
**Next Step:** Implement image/video/audio players

## ✅ Success Criteria

All widgets should:
- [ ] Display correctly on first load
- [ ] Update immediately when data changes
- [ ] Show proper loading states
- [ ] Handle errors gracefully
- [ ] Be responsive to user interaction
- [ ] Match the design specifications
- [ ] Show debug logs in console
- [ ] Work consistently across app restarts

## 🎨 Visual Quality Checklist

- [ ] Proper spacing (using AppTheme constants)
- [ ] Consistent colors (using AppTheme colors)
- [ ] Smooth animations
- [ ] Proper shadows and elevation
- [ ] Rounded corners where appropriate
- [ ] Icons properly sized and colored
- [ ] Text properly sized and weighted
- [ ] Gradients applied correctly
- [ ] Borders and dividers subtle but visible

## 📱 Test Scenarios

### Scenario 1: First Time User
1. Open app (empty state should show)
2. Send first message
3. Message should appear immediately
4. Empty state should disappear

### Scenario 2: Multiple Messages
1. Send 5 text messages
2. All 5 should appear in order
3. Scroll should work smoothly
4. Auto-scroll to bottom after send

### Scenario 3: Mixed Media
1. Send text message
2. Send voice note
3. Send image
4. Send video
5. All should display with correct widgets

### Scenario 4: Reply Thread
1. Send message A
2. Reply to message A with message B
3. Message B should show parent preview
4. Parent preview should show message A info

### Scenario 5: App Restart
1. Send several messages
2. Close app completely
3. Reopen app
4. All messages should still be visible

---

**Created:** October 26, 2025
**Purpose:** Verify threads tab widgets are working correctly
**Status:** Ready for Testing
