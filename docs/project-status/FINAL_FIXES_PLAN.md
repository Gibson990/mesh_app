# Final Fixes & Features Implementation Plan

## 🎯 Issues to Fix

### 1. ✅ CRITICAL - Layout Error (FIXED)
- Fixed `Expanded` in `_buildThreadLine()`
- Added `mainAxisSize.min` to all Columns
- Messages should now display

### 2. 🔧 Attachment with Text (WhatsApp Style)
**Current:** Attachment replaces text
**Required:** Attachment + caption together
**Implementation:**
- Add caption field to attachment modal
- Store both file path and caption in message
- Display image/video with caption below

### 3. 🔧 Image Display
**Current:** Shows file path instead of image
**Required:** Display actual image
**Implementation:**
- Use `Image.file()` to load from path
- Add error handling for missing files
- Add loading placeholder

### 4. 🔧 Media Tab Sync
**Current:** Media sent in threads doesn't appear in media tab
**Required:** All media appears in media tab
**Implementation:**
- Already using `MessageTab` enum correctly
- Need to verify media filtering in media tab

### 5. 🔧 Thread Lines & Parent-Child Display
**Current:** Basic thread line
**Required:** Twitter/YouTube style threading
**Implementation:**
- Vertical lines connecting replies
- Indentation for child messages
- Clear parent-child relationship
- Collapse/expand threads

### 6. 🔧 Bluetooth Connection & Peer Discovery
**Current:** Scanning but not showing peers
**Required:** Show available peers, connect
**Implementation:**
- Display discovered peers in UI
- Allow manual connection
- Show connection status

### 7. ⚠️ Feature Verification Needed
- Local storage (SQLite)
- Internet connectivity check
- Bluetooth mesh transmission
- Encryption
- Compression
- Offline queue

## 📋 Implementation Order

### Phase 1: Critical Display Issues (NOW)
1. ✅ Fix image display - show actual images
2. ✅ Fix attachment with caption
3. ✅ Verify media tab sync

### Phase 2: UI/UX Improvements
4. ✅ Implement thread lines (Twitter style)
5. ✅ Add parent-child indentation
6. ✅ Improve reply visualization

### Phase 3: Connectivity
7. ✅ Show Bluetooth peers
8. ✅ Connection management UI
9. ✅ Verify internet check

### Phase 4: Integration Ready
10. ✅ Verify all local features
11. ✅ Document what's left for Discord/Telegram
12. ✅ Create integration guide

---

## 🚀 Starting Implementation...
