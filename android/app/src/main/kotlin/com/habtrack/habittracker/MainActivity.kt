package com.habtrack.habittracker

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (not FlutterActivity): the `health` plugin needs a
// ComponentActivity to register — with FlutterActivity it failed to load at
// all, so Sync to Health never worked on any device (feedback 7, slide 47).
class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showOverLockScreenIfAlarm(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        showOverLockScreenIfAlarm(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "habtrack/alarm")
            .setMethodCallHandler { call, result ->
                if (call.method == "releaseLockScreen") {
                    setLockScreenFlags(false)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    // A ringing habit alarm (feedback 8, slide 10) opens this activity
    // full-screen; it has to turn the screen on and show above the lock
    // screen so Snooze/Dismiss are reachable without unlocking. Only for an
    // alarm launch — any other launch keeps the normal lock-screen behavior.
    private fun showOverLockScreenIfAlarm(intent: Intent?) {
        if (intent?.action != "SELECT_NOTIFICATION") return
        val payload = intent.getStringExtra("payload") ?: return
        if (!payload.contains("\"type\":\"alarm\"")) return
        setLockScreenFlags(true)
    }

    private fun setLockScreenFlags(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(enabled)
            setTurnScreenOn(enabled)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (enabled) window.addFlags(flags) else window.clearFlags(flags)
        }
    }
}
