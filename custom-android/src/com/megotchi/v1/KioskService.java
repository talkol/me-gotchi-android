package com.megotchi.v1;

import android.app.Service;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;

public class KioskService extends Service {
    private static final String TAG = "KioskService";
    private DevicePolicyManager dpm;
    private ComponentName adminComponent;
    private Handler handler;
    private Runnable kioskCheckRunnable;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "KioskService created");
        
        handler = new Handler(Looper.getMainLooper());
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
            adminComponent = new ComponentName(this, KioskDeviceAdminReceiver.class);
        }
        
        // Create a runnable that continuously checks and maintains kiosk mode
        kioskCheckRunnable = new Runnable() {
            @Override
            public void run() {
                maintainKioskMode();
                // Schedule the next check in 1 second
                handler.postDelayed(this, 1000);
            }
        };
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "KioskService started");
        
        // Start the continuous kiosk mode maintenance
        handler.post(kioskCheckRunnable);
        
        // Return START_STICKY to restart service if killed
        return START_STICKY;
    }

    private void maintainKioskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (dpm.isDeviceOwnerApp(getPackageName())) {
                // Ensure lock task packages are set correctly
                dpm.setLockTaskPackages(adminComponent, new String[]{getPackageName()});
                
                // If we're not in lock task mode, try to start it
                if (!dpm.isLockTaskPermitted(getPackageName())) {
                    Log.d(TAG, "Lock task not permitted, attempting to enable");
                    Intent intent = new Intent(this, GodotApp.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                } else {
                    Log.d(TAG, "Lock task mode is active and permitted");
                }
            } else {
                Log.d(TAG, "App is not device owner");
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "KioskService destroyed");
        
        // Remove the callback
        if (handler != null && kioskCheckRunnable != null) {
            handler.removeCallbacks(kioskCheckRunnable);
        }
        
        // Try to restart the service
        Intent intent = new Intent(this, KioskService.class);
        startService(intent);
    }
} 