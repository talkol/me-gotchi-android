#!/bin/bash

# Setup script for kiosk mode modifications
# This script copies the custom kiosk mode files to the Android build directory

echo "Setting up kiosk mode for Android build..."

# Create necessary directories
mkdir -p android/build/src/com/godot/game
mkdir -p android/build/res/xml

# Copy Java source files
echo "Copying Java source files..."
cp custom-android/src/com/godot/game/*.java android/build/src/com/godot/game/

# Copy resource files
echo "Copying resource files..."
cp custom-android/res/xml/*.xml android/build/res/xml/

# Copy modified AndroidManifest.xml
echo "Copying modified AndroidManifest.xml..."
cp custom-android/AndroidManifest.xml android/build/

echo "Kiosk mode setup complete!"
echo "You can now build your Android app with kiosk mode enabled." 