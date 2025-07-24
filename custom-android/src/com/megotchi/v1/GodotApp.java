/**************************************************************************/
/*  GodotApp.java                                                         */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

package com.megotchi.v1;

import org.godotengine.godot.FullScreenGodotApp;

import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.KeyEvent;

/**
 * Template activity for Godot Android custom builds.
 * Feel free to extend and modify this class for your custom logic.
 */
public class GodotApp extends FullScreenGodotApp {
	@Override
	public void onCreate(Bundle savedInstanceState) {
		// Use the parent class's theme setting instead of explicit R reference
		super.onCreate(savedInstanceState);

		System.out.println("GodotApp: onCreate() called - initializing kiosk mode");

		// Initialize kiosk mode
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			DevicePolicyManager dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
			ComponentName adminComponent = new ComponentName(this, KioskDeviceAdminReceiver.class);

			System.out.println("GodotApp: Checking device owner status...");
			if (dpm.isDeviceOwnerApp(getPackageName())) {
				System.out.println("GodotApp: App is device owner - setting up kiosk mode");
				
				// Set lock task packages to only allow this app
				dpm.setLockTaskPackages(adminComponent, new String[]{getPackageName()});
				System.out.println("GodotApp: Lock task packages set");
				
				// Start lock task mode (kiosk mode)
				startLockTask();
				System.out.println("GodotApp: startLockTask() called");
				
				// Start kiosk service to maintain kiosk mode
				Intent serviceIntent = new Intent(this, KioskService.class);
				startService(serviceIntent);
				System.out.println("GodotApp: KioskService started");
			} else {
				System.out.println("GodotApp: App is NOT device owner - kiosk mode not available");
			}
		} else {
			System.out.println("GodotApp: Android version too old for kiosk mode");
		}
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		System.out.println("GodotApp: dispatchKeyEvent() called with keyCode: " + event.getKeyCode());
		// Block all navigation keys at dispatch level
		if (event.getKeyCode() == KeyEvent.KEYCODE_BACK ||
			event.getKeyCode() == KeyEvent.KEYCODE_HOME ||
			event.getKeyCode() == KeyEvent.KEYCODE_APP_SWITCH ||
			event.getKeyCode() == KeyEvent.KEYCODE_MENU ||
			event.getKeyCode() == KeyEvent.KEYCODE_SEARCH ||
			event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP ||
			event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN ||
			event.getKeyCode() == KeyEvent.KEYCODE_POWER) {
			System.out.println("GodotApp: Blocking keyCode at dispatch level: " + event.getKeyCode());
			return true; // Consume the event, don't let it propagate
		}
		return super.dispatchKeyEvent(event);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		System.out.println("GodotApp: onKeyDown() called with keyCode: " + keyCode);
		// Block all navigation keys
		if (keyCode == KeyEvent.KEYCODE_BACK ||
			keyCode == KeyEvent.KEYCODE_HOME ||
			keyCode == KeyEvent.KEYCODE_APP_SWITCH ||
			keyCode == KeyEvent.KEYCODE_MENU ||
			keyCode == KeyEvent.KEYCODE_SEARCH ||
			keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
			keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
			keyCode == KeyEvent.KEYCODE_POWER) {
			System.out.println("GodotApp: Blocking keyCode: " + keyCode);
			return true; // Consume the event, don't let it propagate
		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		System.out.println("GodotApp: onKeyUp() called with keyCode: " + keyCode);
		// Block the same keys on key up
		if (keyCode == KeyEvent.KEYCODE_BACK ||
			keyCode == KeyEvent.KEYCODE_HOME ||
			keyCode == KeyEvent.KEYCODE_APP_SWITCH ||
			keyCode == KeyEvent.KEYCODE_MENU ||
			keyCode == KeyEvent.KEYCODE_SEARCH ||
			keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
			keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
			keyCode == KeyEvent.KEYCODE_POWER) {
			System.out.println("GodotApp: Blocking keyCode on key up: " + keyCode);
			return true; // Consume the event
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override
	public boolean onKeyLongPress(int keyCode, KeyEvent event) {
		System.out.println("GodotApp: onKeyLongPress() called with keyCode: " + keyCode);
		// Block long press on navigation keys
		if (keyCode == KeyEvent.KEYCODE_BACK ||
			keyCode == KeyEvent.KEYCODE_HOME ||
			keyCode == KeyEvent.KEYCODE_APP_SWITCH ||
			keyCode == KeyEvent.KEYCODE_MENU ||
			keyCode == KeyEvent.KEYCODE_SEARCH ||
			keyCode == KeyEvent.KEYCODE_POWER) {
			System.out.println("GodotApp: Blocking keyCode on long press: " + keyCode);
			return true; // Consume the event
		}
		return super.onKeyLongPress(keyCode, event);
	}

	@Override
	public void onBackPressed() {
		// Override back button to do nothing
		// This prevents the app from being closed
		System.out.println("GodotApp: onBackPressed() called - blocking back button");
		// Don't call super.onBackPressed() to prevent default behavior
	}

	@Override
	public void onPause() {
		// Prevent the app from being paused/backgrounded
		super.onPause();
		// Try to bring the app back to foreground
		Intent intent = new Intent(this, GodotApp.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(intent);
	}

	@Override
	public void onStop() {
		// Prevent the app from being stopped
		super.onStop();
		// Try to bring the app back to foreground
		Intent intent = new Intent(this, GodotApp.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(intent);
	}
}
