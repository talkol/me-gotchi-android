#!/bin/bash

# Setup script for kiosk mode modifications
# This script copies the custom kiosk mode files to the Android build directory
# Note: Uses basic kiosk mode without aggressive foreground service for better sleep compatibility

echo "Setting up kiosk mode for Android build..."

# Clean up old files first
echo "Cleaning up old files..."
rm -rf android/build/src/com/megotchi
rm -rf android/build/res/xml

# Ensure debug keystore is in the right location
if [ ! -f "android/build/debug.keystore" ]; then
    echo "Copying debug keystore..."
    cp debug.keystore android/build/debug.keystore
fi

# Create necessary directories
mkdir -p android/build/src/com/megotchi/v1
mkdir -p android/build/res/xml

# Copy Java source files
echo "Copying Java source files..."
cp custom-android/src/com/megotchi/v1/*.java android/build/src/com/megotchi/v1/

# Copy resource files
echo "Copying resource files..."
cp custom-android/res/xml/*.xml android/build/res/xml/

# Copy modified AndroidManifest.xml
echo "Copying modified AndroidManifest.xml..."
cp custom-android/AndroidManifest.xml android/build/

echo "Kiosk mode setup complete!"
echo "You can now build your Android app with kiosk mode enabled."
echo "Note: This version allows normal sleep behavior while maintaining kiosk restrictions." 