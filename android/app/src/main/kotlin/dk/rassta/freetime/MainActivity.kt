package dk.rassta.freetime

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var store: SessionStore
    private var sink: EventChannel.EventSink? = null

    private val updates = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val s = sink ?: return
            store.drainPending().forEach { s.success(it) }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        store = SessionStore(this)
        SessionService.ensureRunning(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "free_time/methods")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "currentState" -> result.success(DeviceState.snapshot(this, SessionService.running))
                    // Android counts continuously; manual start/stop only exists on iOS.
                    "startSession" -> { SessionService.ensureRunning(this); result.success(null) }
                    "stopSession" -> result.success(store.drainPending())
                    "isSessionRunning" -> result.success(store.getActive() != null)
                    "drainPendingSessions" -> result.success(store.drainPending())
                    "requestPermissions" -> { requestPermissions(); result.success(null) }
                    "diagnosticLog" -> result.success(store.logText())
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "free_time/sessions")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) { sink = events }
                override fun onCancel(args: Any?) { sink = null }
            })
    }

    override fun onResume() {
        super.onResume()
        ContextCompat.registerReceiver(
            this, updates, IntentFilter(SessionService.ACTION_SESSIONS_UPDATED),
            ContextCompat.RECEIVER_NOT_EXPORTED
        )
    }

    override fun onPause() {
        unregisterReceiver(updates)
        super.onPause()
    }

    private fun requestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
        }
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
            startActivity(
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    .setData(Uri.parse("package:$packageName"))
            )
        }
    }
}
