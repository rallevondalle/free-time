package co.componental.free_time

import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.TriggerEvent
import android.hardware.TriggerEventListener
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import kotlin.math.abs
import kotlin.math.sqrt

/**
 * Always-on foreground service. Counts whenever the phone is not in use.
 *
 * "In use"  = screen on AND unlocked → no segment.
 * "Down"    = screen off, or screen on but locked → a segment is open.
 *
 * A segment has exactly one (mode, screenOn, moving) state. Whenever any of
 * those change the current segment is closed and a new one opened:
 *  - ringer / DND / airplane change → mode
 *  - screen on/off               → screenOn (on-but-locked gives fewer points)
 *  - significant motion          → moving=true (unverified); stationary → moving=false
 */
class SessionService : Service() {

    private lateinit var store: SessionStore
    private lateinit var sensors: SensorManager
    private lateinit var power: PowerManager
    private lateinit var keyguard: KeyguardManager
    private val handler = Handler(Looper.getMainLooper())

    private var active: SessionStore.Segment? = null
    private var screenOn = false
    private var moving = false

    // ---- broadcast events ----
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                AudioManager.RINGER_MODE_CHANGED_ACTION,
                NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED,
                Intent.ACTION_AIRPLANE_MODE_CHANGED -> rotateIfChanged()

                Intent.ACTION_SCREEN_OFF -> { screenOn = false; if (active == null) open() else rotateIfChanged() }
                Intent.ACTION_SCREEN_ON -> {
                    screenOn = true
                    if (keyguard.isKeyguardLocked) rotateIfChanged() else close()
                }
                Intent.ACTION_USER_PRESENT -> close()
            }
        }
    }

    private val heartbeat = object : Runnable {
        override fun run() {
            store.heartbeat()
            handler.postDelayed(this, HEARTBEAT_MS)
        }
    }

    // ---- motion: one-shot trigger sensors (low power), accelerometer fallback ----
    private val motionTrigger = object : TriggerEventListener() {
        override fun onTrigger(event: TriggerEvent) { if (!moving) { moving = true; rotateIfChanged() }; armMotionSensors() }
    }
    private val stationaryTrigger = object : TriggerEventListener() {
        override fun onTrigger(event: TriggerEvent) { if (moving) { moving = false; rotateIfChanged() }; armMotionSensors() }
    }
    private var motionStreak = 0
    private var stillStreak = 0
    private val accelFallback = object : SensorEventListener {
        override fun onSensorChanged(e: SensorEvent) {
            val g = sqrt(e.values[0] * e.values[0] + e.values[1] * e.values[1] + e.values[2] * e.values[2])
            val m = abs(g - SensorManager.STANDARD_GRAVITY) > MOTION_THRESHOLD
            motionStreak = if (m) motionStreak + 1 else 0
            stillStreak = if (m) 0 else stillStreak + 1
            if (!moving && motionStreak >= 15) { moving = true; motionStreak = 0; rotateIfChanged() }      // ≈3 s moving
            if (moving && stillStreak >= 150) { moving = false; stillStreak = 0; rotateIfChanged() }       // ≈30 s still
        }
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    private fun armMotionSensors() {
        val sig = sensors.getDefaultSensor(Sensor.TYPE_SIGNIFICANT_MOTION)
        val stat = sensors.getDefaultSensor(Sensor.TYPE_STATIONARY_DETECT)
        if (sig != null && stat != null) {
            if (moving) sensors.requestTriggerSensor(stationaryTrigger, stat)
            else sensors.requestTriggerSensor(motionTrigger, sig)
        } else {
            sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.let {
                sensors.registerListener(accelFallback, it, SensorManager.SENSOR_DELAY_NORMAL)
            }
        }
    }

    private fun disarmMotionSensors() {
        sensors.getDefaultSensor(Sensor.TYPE_SIGNIFICANT_MOTION)?.let { sensors.cancelTriggerSensor(motionTrigger, it) }
        sensors.getDefaultSensor(Sensor.TYPE_STATIONARY_DETECT)?.let { sensors.cancelTriggerSensor(stationaryTrigger, it) }
        sensors.unregisterListener(accelFallback)
    }

    // ---- lifecycle ----
    override fun onCreate() {
        super.onCreate()
        store = SessionStore(this)
        sensors = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        power = getSystemService(Context.POWER_SERVICE) as PowerManager
        keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        registerReceiver(receiver, IntentFilter().apply {
            addAction(AudioManager.RINGER_MODE_CHANGED_ACTION)
            addAction(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
            addAction(Intent.ACTION_AIRPLANE_MODE_CHANGED)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        })
        handler.post(heartbeat)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground()
        running = true
        // Reconcile with reality: a segment left in the store from a previous
        // process is resumed only if the phone is still "down".
        screenOn = power.isInteractive
        val inUse = screenOn && !keyguard.isKeyguardLocked
        if (active == null) active = store.getActive()
        if (inUse) close() else if (active == null) open() else rotateIfChanged()
        return START_STICKY
    }

    private fun open() {
        if (active != null) return
        active = SessionStore.Segment(
            startedAt = System.currentTimeMillis(),
            mode = DeviceState.mode(this),
            source = "auto",
            screenOn = screenOn,
            verified = !moving,
        )
        store.setActive(active)
        armMotionSensors()
        updateNotification()
    }

    /** Close the current segment and open a fresh one if any state changed. */
    private fun rotateIfChanged() {
        val seg = active ?: return
        val mode = DeviceState.mode(this)
        if (mode == seg.mode && screenOn == seg.screenOn && !moving == seg.verified) return
        val t = System.currentTimeMillis()
        seg.endedAt = t
        store.addPending(seg)
        active = SessionStore.Segment(startedAt = t, mode = mode, source = "auto", screenOn = screenOn, verified = !moving)
        store.setActive(active)
        updateNotification()
        notifyFlutter()
    }

    private fun close() {
        val seg = active ?: return
        seg.endedAt = System.currentTimeMillis()
        store.addPending(seg)
        active = null
        store.setActive(null)
        disarmMotionSensors()
        updateNotification()
        notifyFlutter()
    }

    private fun notifyFlutter() = sendBroadcast(Intent(ACTION_SESSIONS_UPDATED).setPackage(packageName))

    // ---- foreground plumbing ----
    private fun notification(): Notification {
        val open = PendingIntent.getActivity(
            this, 0, packageManager.getLaunchIntentForPackage(packageName), PendingIntent.FLAG_IMMUTABLE
        )
        val text = when {
            active == null -> "Telefonen er i brug. Lås den for at tjene point."
            else -> "Tæller point: ${DeviceState.label(active!!.mode)}" +
                (if (active!!.screenOn) ", skærm tændt" else "") +
                (if (!active!!.verified) ", i bevægelse" else "")
        }
        return Notification.Builder(this, CHANNEL)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentTitle("Free Time")
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun startForeground() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(NotificationChannel(CHANNEL, "Tæller", NotificationManager.IMPORTANCE_MIN))
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIF_ID, notification(), ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIF_ID, notification())
        }
    }

    private fun updateNotification() {
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).notify(NOTIF_ID, notification())
    }

    override fun onDestroy() {
        unregisterReceiver(receiver)
        disarmMotionSensors()
        handler.removeCallbacks(heartbeat)
        running = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val ACTION_SESSIONS_UPDATED = "co.componental.free_time.SESSIONS_UPDATED"
        private const val CHANNEL = "tracker"
        private const val NOTIF_ID = 1
        private const val HEARTBEAT_MS = 60_000L
        private const val MOTION_THRESHOLD = 0.8f // m/s²

        @Volatile var running = false

        fun ensureRunning(context: Context) =
            context.startForegroundService(Intent(context, SessionService::class.java))
    }
}
