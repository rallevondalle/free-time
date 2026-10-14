package co.componental.free_time

import android.app.NotificationManager
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

    fun label(mode: String) = when (mode) {
        "vibrate" -> "vibrer"; "silent" -> "lydløs"; "dnd" -> "forstyr ikke"
        "airplane" -> "flytilstand"; "powered_off" -> "slukket"; else -> "lyd"
    }

    fun snapshot(context: Context, serviceRunning: Boolean): Map<String, Any> = mapOf(
        "mode" to mode(context),
        "canMeasureRinger" to true,
        "canMeasureAirplane" to true,
        "canMeasureDnd" to true,
        "serviceRunning" to serviceRunning,
    )
}
