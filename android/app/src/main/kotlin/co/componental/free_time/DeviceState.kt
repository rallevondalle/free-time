package co.componental.free_time

import android.app.NotificationManager
import android.bluetooth.BluetoothManager
import android.net.wifi.WifiManager
import android.content.Context
import android.media.AudioManager
import android.provider.Settings

/** Reads the device state that affects scoring and maps it to a session mode. */
object DeviceState {
    fun mode(context: Context): String {
        val airplane = Settings.Global.getInt(
            context.contentResolver, Settings.Global.AIRPLANE_MODE_ON, 0
        ) == 1
        if (airplane) return "airplane"

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val dnd = nm.currentInterruptionFilter.let {
            it == NotificationManager.INTERRUPTION_FILTER_NONE ||
                it == NotificationManager.INTERRUPTION_FILTER_PRIORITY ||
                it == NotificationManager.INTERRUPTION_FILTER_ALARMS
        }
        if (dnd) return "dnd"

        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return when (am.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> "silent"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "normal"
        }
    }

    fun label(context: Context, mode: String): String = context.getString(when (mode) {
        "vibrate" -> R.string.mode_vibrate; "silent" -> R.string.mode_silent; "dnd" -> R.string.mode_dnd
        "airplane" -> R.string.mode_airplane; "powered_off" -> R.string.mode_powered_off; else -> R.string.mode_normal
    })

    /** Wi-Fi radio switched on (airplane mode does not switch it off by itself). */
    // Both reads are wrapped: a SecurityException here killed the whole counter
    // on 14/10-2026. Unknown radio state must never cost the user their session.
    fun wifiOn(context: Context): Boolean = try {
        (context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager)?.isWifiEnabled ?: false
    } catch (e: Exception) { false }

    /** Bluetooth radio switched on. Reading the adapter state needs no runtime permission. */
    fun bluetoothOn(context: Context): Boolean = try {
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter?.isEnabled ?: false
    } catch (e: Exception) { false }

    fun snapshot(context: Context, serviceRunning: Boolean): Map<String, Any> = mapOf(
        "mode" to mode(context),
        "wifiOn" to wifiOn(context),
        "bluetoothOn" to bluetoothOn(context),
        "canMeasureRinger" to true,
        "canMeasureAirplane" to true,
        "canMeasureDnd" to true,
        "serviceRunning" to serviceRunning,
    )
}
