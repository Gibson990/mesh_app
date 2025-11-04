# 🚀 Telegram & Discord Setup Guide

## ✅ WHAT'S IMPLEMENTED

### Auto-Upload Features:
- ✅ **ONLY MEDIA files** auto-upload (images, videos, audio)
- ✅ **Text messages** are NOT uploaded (only screenshot when shared manually)
- ✅ **Compressed media** before upload
- ✅ **Secure storage** for credentials (Flutter Secure Storage)
- ✅ **Offline queue** - uploads when internet available
- ✅ **Auto-retry** on failure
- ✅ **Fast & automated**

---

## 📱 TELEGRAM SETUP (Step-by-Step)

### Step 1: Create a Telegram Bot

1. **Open Telegram** on your phone or computer

2. **Search for @BotFather** in the search bar

3. **Start a chat** with BotFather

4. **Send this command:**
   ```
   /newbot
   ```

5. **BotFather will ask for a name:**
   - Example: "My Mesh App Bot"
   - Type your bot name and send

6. **BotFather will ask for a username:**
   - Must end with "bot"
   - Example: "my_mesh_app_bot"
   - Type username and send

7. **BotFather will reply with your Bot Token:**
   ```
   Use this token to access the HTTP API:
   123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
   **⚠️ SAVE THIS TOKEN - You'll need it!**

---

### Step 2: Get Your Chat ID

1. **Send a message to your bot**
   - Search for your bot username in Telegram
   - Start a chat
   - Send any message (e.g., "Hello")

2. **Open this URL in your browser:**
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
   Replace `<YOUR_BOT_TOKEN>` with your actual token

3. **Look for this in the response:**
   ```json
   {
     "ok": true,
     "result": [
       {
         "message": {
           "chat": {
             "id": 123456789,
             ...
           }
         }
       }
     ]
   }
   ```
   **The number after "id": is your Chat ID**
   **⚠️ SAVE THIS CHAT ID - You'll need it!**

---

### Step 3: Configure in App

1. **Open the Mesh App**

2. **Go to Settings** (or External Platforms Config screen)

3. **Enter your credentials:**
   - **Bot Token:** Paste the token from Step 1
   - **Chat ID:** Paste the chat ID from Step 2

4. **Click "Save Telegram Config"**

5. **You should see "Configured" badge**

---

## 💬 DISCORD SETUP (Step-by-Step)

### Step 1: Create a Discord Webhook

1. **Open Discord** on your computer or phone

2. **Go to your server** where you want media uploaded

3. **Select the channel** where media should appear

4. **Right-click on the channel name**

5. **Click "Edit Channel"**

6. **Go to "Integrations" tab** (left sidebar)

7. **Click "Create Webhook"** or "View Webhooks"

8. **Click "New Webhook"**

9. **Give it a name:**
   - Example: "Mesh App Media"

10. **Click "Copy Webhook URL"**
    - URL looks like: `https://discord.com/api/webhooks/123456789/abcdefghijklmnop`
    **⚠️ SAVE THIS URL - You'll need it!**

---

### Step 2: Configure in App

1. **Open the Mesh App**

2. **Go to Settings** (or External Platforms Config screen)

3. **Enter your webhook:**
   - **Webhook URL:** Paste the URL from Step 1

4. **Click "Save Discord Config"**

5. **You should see "Configured" badge**

---

## 🧪 TESTING

### Test Telegram Upload:

1. **Take a photo** or select an image in the app

2. **Send it** in the Threads tab

3. **Check your Telegram bot chat**
   - Image should appear within seconds
   - Caption should be included

### Test Discord Upload:

1. **Take a photo** or select an image in the app

2. **Send it** in the Threads tab

3. **Check your Discord channel**
   - Image should appear within seconds
   - Caption should be included

---

## 📋 CONFIGURATION CHECKLIST

### Before Testing:
- [ ] Telegram bot created
- [ ] Bot token saved
- [ ] Chat ID obtained
- [ ] Telegram configured in app
- [ ] Discord webhook created
- [ ] Webhook URL saved
- [ ] Discord configured in app

### After Configuration:
- [ ] Test image upload to Telegram
- [ ] Test image upload to Discord
- [ ] Test video upload to Telegram
- [ ] Test video upload to Discord
- [ ] Test audio upload to Telegram
- [ ] Test audio upload to Discord
- [ ] Test offline queue (turn off internet, send media, turn on internet)
- [ ] Verify compression working (check file sizes)

---

## 🔒 SECURITY

### Credentials Storage:
- ✅ **Flutter Secure Storage** used
- ✅ Encrypted on device
- ✅ Not stored in plain text
- ✅ Secure even if device is rooted

### Best Practices:
- ⚠️ **Never share your bot token**
- ⚠️ **Never commit tokens to git**
- ⚠️ **Revoke and recreate if compromised**
- ⚠️ **Use different bots for testing/production**

---

## 🎯 HOW IT WORKS

### Upload Flow:

```
1. User sends media (image/video/audio)
   ↓
2. Media is compressed (85% quality, 1920px max)
   ↓
3. Message sent via Bluetooth to mesh
   ↓
4. Media queued for external upload
   ↓
5. If online → Upload immediately
   If offline → Queue for later
   ↓
6. Upload to Telegram (if configured)
   ↓
7. Upload to Discord (if configured)
   ↓
8. Done! ✅
```

### What Gets Uploaded:
- ✅ **Images** (compressed)
- ✅ **Videos** (compressed)
- ✅ **Audio files**
- ✅ **Captions** (included with media)
- ❌ **Text messages** (NOT uploaded)
- ❌ **Voice notes** (NOT uploaded)

### When Uploads Happen:
- ✅ **Immediately** if online
- ✅ **Automatically** when internet returns
- ✅ **In background** (doesn't block UI)
- ✅ **With retry** (up to 5 attempts)

---

## 🔧 TROUBLESHOOTING

### Telegram Not Working:

**Problem:** Media not appearing in Telegram

**Solutions:**
1. Check bot token is correct
2. Check chat ID is correct
3. Send a message to bot first (to activate chat)
4. Check internet connection
5. Check app logs for errors

**Verify Token:**
```
https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```
Should return bot info

---

### Discord Not Working:

**Problem:** Media not appearing in Discord

**Solutions:**
1. Check webhook URL is correct
2. Check webhook is not deleted
3. Check channel permissions
4. Check internet connection
5. Check app logs for errors

**Verify Webhook:**
- Go to Discord channel settings
- Check "Integrations" → "Webhooks"
- Webhook should be listed

---

### Offline Queue Not Processing:

**Problem:** Media sent offline not uploading when online

**Solutions:**
1. Check internet connection
2. Restart app
3. Check queue status in settings
4. Check app logs

---

### Compression Not Working:

**Problem:** Files too large

**Solutions:**
1. Check compression settings (should be 85% quality)
2. Check max resolution (should be 1920px)
3. Check file type (only images/videos compressed)
4. Check app logs for compression errors

---

## 📊 MONITORING

### Check Upload Status:

1. **Open Settings** → External Platforms Config

2. **View Queue Status:**
   - Queue Length: Number of pending uploads
   - Status: Uploading or Idle
   - Connection: Online or Offline

3. **Check Logs:**
   - Look for: `[ExternalPlatforms]` logs
   - Look for: `✅ Uploaded to Telegram`
   - Look for: `✅ Uploaded to Discord`

---

## 🚀 PRODUCTION DEPLOYMENT

### Before Launch:

1. **Test all features:**
   - [ ] Image upload
   - [ ] Video upload
   - [ ] Audio upload
   - [ ] Offline queue
   - [ ] Compression
   - [ ] Telegram upload
   - [ ] Discord upload

2. **Create production bots/webhooks:**
   - [ ] Separate from testing
   - [ ] Proper naming
   - [ ] Secure storage

3. **Configure in app:**
   - [ ] Production Telegram bot
   - [ ] Production Discord webhook
   - [ ] Test end-to-end

4. **Monitor:**
   - [ ] Check queue regularly
   - [ ] Check upload success rate
   - [ ] Check compression ratio
   - [ ] Check battery usage

---

## 📝 EXAMPLE CREDENTIALS

### Telegram Example:
```
Bot Token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz-1234567
Chat ID: 987654321
```

### Discord Example:
```
Webhook URL: https://discord.com/api/webhooks/123456789012345678/abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP
```

---

## 🎉 SUCCESS INDICATORS

### You'll Know It's Working When:

1. **Telegram:**
   - Media appears in bot chat immediately
   - Caption is included
   - Sender name is shown
   - File is compressed

2. **Discord:**
   - Media appears in channel immediately
   - Caption is included
   - Sender name is shown
   - File is compressed

3. **Queue:**
   - Queue length is 0 when online
   - Queue processes automatically
   - Failed uploads retry

4. **Logs:**
   - See: `✅ [ExternalPlatforms] Uploaded to Telegram`
   - See: `✅ [ExternalPlatforms] Uploaded to Discord`
   - See: `📤 [MessageController] Queuing media for external upload`

---

## 🔥 QUICK START (TL;DR)

### Telegram:
1. Message @BotFather → `/newbot`
2. Get token
3. Message your bot
4. Get chat ID from `https://api.telegram.org/bot<TOKEN>/getUpdates`
5. Enter in app → Save

### Discord:
1. Right-click channel → Edit Channel
2. Integrations → Create Webhook
3. Copy Webhook URL
4. Enter in app → Save

### Test:
1. Send image in app
2. Check Telegram bot chat
3. Check Discord channel
4. Should appear in seconds!

---

**Status:** ✅ READY FOR CONFIGURATION
**Next:** Configure your Telegram bot and Discord webhook
**Then:** Test uploads and verify everything works!
