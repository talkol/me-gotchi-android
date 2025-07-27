# Kiosk Mode Setup After Factory Reset

## Prerequisites

1. Device has been factory reset
2. Developer Options enabled
3. USB Debugging enabled
4. Device connected via USB
5. ADB authorized on device
6. `release.keystore` file placed in the `android-app/` directory (for production APK signing)
   
   **If you don't have a release.keystore file, create one with:**
   ```bash
   keytool -genkey -v -keystore release.keystore -alias megotchi -keyalg RSA -keysize 2048 -validity 10000
   ```
   
   **Note:** The release keystore is used for production builds and should be kept secure. The debug.keystore is used for development builds and can be shared with the team. The release keystore password should be "trustno1".

## Quick Setup (Recommended)

Run the automated script:
```bash
./build-and-install.sh
```

This script will:
1. Set up kiosk mode files
2. Build the APK with correct package name
3. Install the APK
4. Set device owner
5. Start the app in kiosk mode

## Manual Setup (if script fails)

### 1. Set up kiosk mode files
```bash
./setup-kiosk-mode.sh
```

### 2. Build the APK
```bash
cd android/build
./gradlew clean assembleRelease -Pexport_package_name=com.megotchi.v1 -Prelease_keystore_file=../../release.keystore -Prelease_keystore_password=trustno1 -Prelease_keystore_alias=megotchi -Pperform_signing=true
```

### 3. Install the APK
```bash
adb install -r -t build/outputs/apk/release/android_release.apk
```

### 4. Set device owner
```bash
adb shell dpm set-device-owner com.megotchi.v1/.KioskDeviceAdminReceiver
```

### 5. Start the app
```bash
adb shell am start -n com.megotchi.v1/com.megotchi.v1.GodotApp
```

## Disabling Kiosk Mode

If you need to turn off kiosk mode (e.g., to uninstall the app or use the device normally):

### 1. Remove device owner (requires testOnly flag)
```bash
adb shell dpm remove-active-admin com.megotchi.v1/.KioskDeviceAdminReceiver
```

### 2. Stop lock task mode
```bash
adb shell am force-stop com.megotchi.v1
```

### 3. Uninstall the app
```bash
adb uninstall com.megotchi.v1
```

**Note:** The `testOnly` flag in the app's manifest allows the device owner to be removed. Without this flag, you would need to factory reset the device to remove kiosk mode.

## Features

The kiosk mode includes:
- ✅ Back button blocked
- ✅ Home button blocked
- ✅ Recent apps button blocked
- ✅ Volume buttons blocked
- ✅ Power button blocked
- ✅ Full screen mode
- ✅ Continuous kiosk monitoring
- ✅ Auto-restart if app is killed 