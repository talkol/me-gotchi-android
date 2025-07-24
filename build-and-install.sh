#!/bin/bash

echo "=== Building and Installing Kiosk Mode APK ==="

# Set up kiosk mode
echo "1. Setting up kiosk mode files..."
./setup-kiosk-mode.sh

# Build the APK
echo "2. Building APK with custom package name..."
cd android/build
./gradlew clean assembleDebug -Pexport_package_name=com.megotchi.v1 -Pdebug_keystore_file=../debug.keystore -Pperform_signing=true

# Check if build was successful
if [ $? -eq 0 ]; then
            echo "3. Build successful! Installing APK..."
        adb install -r -t build/outputs/apk/debug/android_debug.apk
    
    if [ $? -eq 0 ]; then
        echo "4. APK installed successfully!"
        echo "5. Checking if device owner is already set..."
        
        # Check if device owner is already set
        if adb shell dumpsys device_policy | grep -q "package=com.megotchi.v1"; then
            echo "6. Device owner already set - skipping..."
        else
            echo "6. Setting device owner..."
            adb shell dpm set-device-owner com.megotchi.v1/.KioskDeviceAdminReceiver
            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to set device owner"
                exit 1
            fi
        fi
        
        echo "7. Starting app in kiosk mode..."
        adb shell am start -n com.megotchi.v1/com.megotchi.v1.GodotApp
        echo "=== Kiosk mode setup complete! ==="
    else
        echo "ERROR: Failed to install APK"
    fi
else
    echo "ERROR: Build failed"
fi

cd ../.. 