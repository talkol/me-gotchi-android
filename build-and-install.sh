#!/bin/bash

echo "=== Building and Installing Kiosk Mode APK ==="

echo "Did you remember to export Android from Godot? (this updates the assets, build will probably fail)

# Set up kiosk mode
echo "1. Setting up kiosk mode files..."
./setup-kiosk-mode.sh

# Clear build cache
echo "2. Clearing build cache and artifacts..."
cd android/build
./gradlew clean
rm -rf .gradle
rm -rf build/build/outputs
echo "Build cache cleared!"

# Build the APK
echo "3. Building RELEASE APK with custom package name..."
./gradlew clean assembleRelease -Pexport_package_name=com.megotchi.v1 -Pdebug_keystore_file=../debug.keystore -Prelease_keystore_file=../../release.keystore -Prelease_keystore_password=trustno1 -Prelease_keystore_alias=megotchi -Pperform_signing=true

# Check if build was successful
if [ $? -eq 0 ]; then
            echo "4. Build successful! Installing APK..."
        adb install -r -t build/outputs/apk/release/android_release.apk
    
    if [ $? -eq 0 ]; then
        echo "5. APK installed successfully!"
        echo "6. Checking if device owner is already set..."
        
        # Check if device owner is already set
        if adb shell dumpsys device_policy | grep -q "package=com.megotchi.v1"; then
            echo "7. Device owner already set - skipping..."
        else
            echo "7. Setting device owner..."
            adb shell dpm set-device-owner com.megotchi.v1/.KioskDeviceAdminReceiver
            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to set device owner"
                exit 1
            fi
        fi
        
        echo "8. Starting app in kiosk mode..."
        adb shell am start -n com.megotchi.v1/com.megotchi.v1.GodotApp
        echo "=== Kiosk mode setup complete! ==="
    else
        echo "ERROR: Failed to install APK"
    fi
else
    echo "ERROR: Build failed"
fi

cd ../.. 