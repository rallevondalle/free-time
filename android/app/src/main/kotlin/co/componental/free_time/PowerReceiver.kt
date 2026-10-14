package co.componental.free_time

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock

/**
 * Turns shutdown/boot into sessions.
 *
 * ACTION_SHUTDOWN: close the active segment, remember when and in which mode.
 * BOOT_COMPLETED:  gap = boot − shutdown. Short gap → reboot bonus,
 *                  longer gap → powered_off session.
 */
class PowerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val store = SessionStore(context)
        when (intent.action) {
            Intent.ACTION_SHUTDOWN, Intent.ACTION_REBOOT -> {
                val now = System.currentTimeMillis()
                store.getActive()?.let { seg ->
                    seg.endedAt = now
                    store.addPending(seg)
                    store.setActive(null)
                }
                store.setShutdownAt(now)
            }
            Intent.ACTION_BOOT_COMPLETED -> {
                SessionService.ensureRunning(context)
                val bootAt = System.currentTimeMillis() - SystemClock.elapsedRealtime()
                if (bootAt <= store.lastBootAt()) return // already handled
                store.setLastBootAt(bootAt)

                val explicit = store.shutdownAt()
                val shutdownAt = if (explicit > 0) explicit else store.lastAlive()
                store.clearShutdown()
                if (shutdownAt <= 0 || bootAt <= shutdownAt) return

                val gap = bootAt - shutdownAt
                if (gap < REBOOT_MAX_GAP_MS) {
                    store.addPending(
                        SessionStore.Segment(
                            startedAt = shutdownAt, endedAt = bootAt,
                            mode = "powered_off", source = "reboot",
                            verified = explicit > 0,
                        )
                    )
                } else {
                    store.addPending(
                        SessionStore.Segment(
                            startedAt = shutdownAt, endedAt = bootAt,
                            mode = "powered_off", source = "shutdown",
                            verified = explicit > 0,
                        )
                    )
                }
            }
        }
    }

    companion object {
        private const val REBOOT_MAX_GAP_MS = 3 * 60_000L
    }
}
