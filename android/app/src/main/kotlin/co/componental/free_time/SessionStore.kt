package co.componental.free_time

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/**
 * Single source of truth for finished sessions waiting to be uploaded, and
 * for the segment that is currently running (so a shutdown receiver can
 * close it even if the service is gone).
 */
class SessionStore(context: Context) {
    private val prefs = context.getSharedPreferences("free_time", Context.MODE_PRIVATE)

    data class Segment(
        val clientId: String = UUID.randomUUID().toString(),
        val startedAt: Long,
        var endedAt: Long = 0L,
        val mode: String,
        val source: String,
        var verified: Boolean = true,
        val selfReported: Boolean = false,
        var pickups: Int = 0,
        val screenOn: Boolean = false,
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("clientId", clientId); put("startedAt", startedAt); put("endedAt", endedAt)
            put("mode", mode); put("source", source); put("verified", verified)
            put("selfReported", selfReported); put("pickups", pickups); put("screenOn", screenOn)
        }
        fun toMap(): Map<String, Any> = mapOf(
            "clientId" to clientId, "startedAt" to startedAt, "endedAt" to endedAt,
            "mode" to mode, "source" to source, "verified" to verified,
            "selfReported" to selfReported, "pickups" to pickups, "screenOn" to screenOn,
        )
        companion object {
            fun fromJson(o: JSONObject) = Segment(
                clientId = o.getString("clientId"), startedAt = o.getLong("startedAt"),
                endedAt = o.optLong("endedAt"), mode = o.getString("mode"),
                source = o.getString("source"), verified = o.optBoolean("verified", true),
                selfReported = o.optBoolean("selfReported", false), pickups = o.optInt("pickups"),
                screenOn = o.optBoolean("screenOn", false),
            )
        }
    }

    // ---- pending (finished) segments ----
    @Synchronized
    fun addPending(seg: Segment) {
        if (seg.endedAt - seg.startedAt < MIN_SEGMENT_MS && seg.source != "reboot") return
        val arr = JSONArray(prefs.getString(KEY_PENDING, "[]"))
        arr.put(seg.toJson())
        prefs.edit().putString(KEY_PENDING, arr.toString()).commit()
    }

    @Synchronized
    fun drainPending(): List<Map<String, Any>> {
        val arr = JSONArray(prefs.getString(KEY_PENDING, "[]"))
        val out = (0 until arr.length()).map { Segment.fromJson(arr.getJSONObject(it)).toMap() }
        prefs.edit().remove(KEY_PENDING).commit()
        return out
    }

    // ---- active segment ----
    @Synchronized
    fun setActive(seg: Segment?) {
        prefs.edit().apply {
            if (seg == null) remove(KEY_ACTIVE) else putString(KEY_ACTIVE, seg.toJson().toString())
        }.commit()
    }

    @Synchronized
    fun getActive(): Segment? =
        prefs.getString(KEY_ACTIVE, null)?.let { Segment.fromJson(JSONObject(it)) }

    // ---- liveness / shutdown bookkeeping ----
    fun heartbeat() = prefs.edit().putLong(KEY_LAST_ALIVE, System.currentTimeMillis()).commit()
    fun lastAlive(): Long = prefs.getLong(KEY_LAST_ALIVE, 0L)
    fun setShutdownAt(t: Long) = prefs.edit().putLong(KEY_SHUTDOWN_AT, t).commit()
    fun shutdownAt(): Long = prefs.getLong(KEY_SHUTDOWN_AT, 0L)
    fun clearShutdown() = prefs.edit().remove(KEY_SHUTDOWN_AT).commit()
    fun lastBootAt(): Long = prefs.getLong(KEY_LAST_BOOT, 0L)
    fun setLastBootAt(t: Long) = prefs.edit().putLong(KEY_LAST_BOOT, t).commit()

    companion object {
        const val MIN_SEGMENT_MS = 30_000L
        private const val KEY_PENDING = "pending"
        private const val KEY_ACTIVE = "active"
        private const val KEY_LAST_ALIVE = "last_alive"
        private const val KEY_SHUTDOWN_AT = "shutdown_at"
        private const val KEY_LAST_BOOT = "last_boot"
    }
}
