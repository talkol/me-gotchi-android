# Android Kiosk Mode Customizations

This directory contains the custom Android modifications needed to enable kiosk mode and auto-start functionality for the Me-Gotchi app.

## Files Overview

### Java Source Files (`src/com/godot/game/`)
- **GodotApp.java** - Modified main activity with kiosk mode initialization
- **KioskDeviceAdminReceiver.java** - Device admin receiver for kiosk functionality
- **BootReceiver.java** - Broadcast receiver for auto-start on boot

### Resource Files (`res/xml/`)
- **device_admin_receiver.xml** - Device admin configuration

### Configuration Files
- **AndroidManifest.xml** - Modified manifest with kiosk permissions and receivers

## Setup Instructions

0. **Make sure default Android export is installed** through Godot (in android folder)

1. **Run the setup script** to copy files to the build directory:
   ```bash
   cd android-app
   ./setup-kiosk-mode.sh
   ```

2. **Build your app** in Godot using the Android export template

3. **Set up device owner** (requires factory reset):
   ```bash
   adb install your-app.apk
   adb shell dpm set-device-owner com.megotchi.v1/.KioskDeviceAdminReceiver
   ```

## Features

- ✅ **Kiosk Mode** - Locks device to the app
- ✅ **Auto-start on Boot** - App starts automatically when device boots
- ✅ **System UI Blocking** - Prevents access to system navigation

## Notes

- These files are tracked in git and should be copied to `android/build/` before building
- The `android/build/` directory is gitignored, so changes there won't be tracked
- Always run the setup script after pulling changes or when setting up on a new machine 