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
                store.log("receiver: ${intent.action?.substringAfterLast('.')}")
                store.getActive()?.let { seg ->
                    seg.endedAt = now
                    store.addPending(seg)
                    store.setActive(null)
                }
                store.setShutdownAt(now)
            }
            // An app update (Obtainium, Play) kills the process, and nothing
            // restarts a foreground service by itself. Without this the counter
            // is dead from the update until the app is next opened.
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                store.log("receiver: package replaced → service start")
                SessionService.ensureRunning(context)
            }
            Intent.ACTION_BOOT_COMPLETED -> {
                SessionService.ensureRunning(context)
                val bootAt = System.currentTimeMillis() - SystemClock.elapsedRealtime()
                if (bootAt <= store.lastBootAt()) { store.log("boot: already handled"); return }
                store.setLastBootAt(bootAt)

                val explicit = store.shutdownAt()
                val shutdownAt = if (explicit > 0) explicit else store.lastAlive()
                store.clearShutdown()
                val gap = bootAt - shutdownAt
                store.log("boot: gap=${gap / 1000}s explicit=${explicit > 0} shutdownAt=$shutdownAt")
                if (shutdownAt <= 0 || bootAt <= shutdownAt) return

                if (gap < REBOOT_MAX_GAP_MS) {
                    store.log("boot: reboot session (+bonus)")
                    store.addPending(
                        SessionStore.Segment(
                            startedAt = shutdownAt, endedAt = bootAt,
                            mode = "powered_off", source = "reboot",
                            verified = explicit > 0,
                        )
                    )
                } else {
                    store.log("boot: powered_off session ${gap / 60000} min")
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
