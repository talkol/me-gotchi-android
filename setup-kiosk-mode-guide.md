Note: The following guide has been implemented inside the directory custom-android/
See custom-android/README.md for instructions

# Godot 3.6 Android Template – Kiosk Mode + Start on Boot

This guide explains how to modify the Android export template in Godot 3.6 to:
- Enable **kiosk mode** (lock the device to the Godot app)
- Automatically **start the app on boot**

> ⚠️ Requires setting your app as **Device Owner** via ADB on a freshly reset device.

---

## ✅ Step 1: Modify AndroidManifest.xml

Edit `android/build/AndroidManifest.xml`:

### 1.1 Update the `<activity>` block:
```xml
<activity
    android:name="org.godotengine.godot.Godot"
    android:label="@string/app_name"
    android:launchMode="singleTask"
    android:theme="@style/GodotAppMainTheme"
    android:configChanges="orientation|screenSize|keyboardHidden"
    android:screenOrientation="sensorLandscape"
    android:lockTaskMode="if_whitelisted"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

### 1.2 Add permissions at the top:
```xml
<uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.BIND_DEVICE_ADMIN"/>
```

### 1.3 Add Device Admin Receiver:
```xml
<receiver
    android:name=".KioskDeviceAdminReceiver"
    android:permission="android.permission.BIND_DEVICE_ADMIN">
    <meta-data
        android:name="android.app.device_admin"
        android:resource="@xml/device_admin_receiver" />
    <intent-filter>
        <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
    </intent-filter>
</receiver>
```

### 1.4 Add Boot Receiver:
```xml
<receiver android:name=".BootReceiver" android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

---

## ✅ Step 2: Create Java Classes

Create these files inside:
`android/src/org/godotengine/godot/`

### 2.1 KioskDeviceAdminReceiver.java
```java
package org.godotengine.godot;

import android.app.admin.DeviceAdminReceiver;

public class KioskDeviceAdminReceiver extends DeviceAdminReceiver {
}
```

### 2.2 BootReceiver.java
```java
package org.godotengine.godot;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Intent i = new Intent(context, Godot.class);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(i);
        }
    }
}
```

---

## ✅ Step 3: Modify Godot.java (Main Activity)

Open `android/src/org/godotengine/godot/Godot.java`  
Add this code to the top of `onCreate()`:

```java
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.os.Build;

@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        DevicePolicyManager dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
        ComponentName adminComponent = new ComponentName(this, KioskDeviceAdminReceiver.class);

        if (dpm.isDeviceOwnerApp(getPackageName())) {
            dpm.setLockTaskPackages(adminComponent, new String[]{getPackageName()});
            startLockTask(); // Enters kiosk mode
        }
    }
}
```

---

## ✅ Step 4: Add Device Admin XML

Create the file:
`android/src/org/godotengine/godot/res/xml/device_admin_receiver.xml`

```xml
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <force-lock/>
    </uses-policies>
</device-admin>
```

---

## ✅ Step 5: Build and Export APK

1. Export your game using this modified template in Godot 3.6.
2. Do **not sign the APK** if you plan to sign it manually.
3. Use `apksigner` to sign the APK with your release key (if needed).

---

## ✅ Step 6: Set as Device Owner

> ⚠️ Must be done right after factory reset — no Google account or setup screens completed.

Install the APK and run:
```bash
adb install mygame.apk
adb shell dpm set-device-owner org.godotengine.godot/.KioskDeviceAdminReceiver
```

If successful, the app will:
- Auto-start on boot
- Run in kiosk mode (user cannot exit)
- Block system UI

---

## ✅ Optional: Exiting Kiosk Mode

To exit kiosk mode (for debugging or admin):
```bash
adb shell dpm remove-active-admin org.godotengine.godot/.KioskDeviceAdminReceiver
```

You can also code a hidden menu in Godot to call `stopLockTask()` via a custom Java bridge if needed.

---

## 🧾 Final Notes

- Device must be factory reset before setting Device Owner
- If the APK is not signed, Android may refuse to install it
- Always test with a dedicated test device