# Universal

A personal all-in-one app. Currently features a checklist, with more tools to come.

## Features

- Checklist with drag-and-drop reordering
- Dark mode support
- Auto-save with local storage

## Download

Get the latest APK from the [Releases](../../releases) page.

## Build Setup

### APK Signing

I know this is unsafe, I just want it to be easy. No one except me is using this app.

1. **Generate a keystore**:
   ```powershell
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Update `android/key.properties`** with your password:
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. **Commit both files** to the repo
