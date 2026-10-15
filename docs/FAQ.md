# Free Time – questions and answers

Contact: **freetime@rassta.dk** · [Dansk version](FAQ.da.md)

## What is Free Time?

Free Time is the opposite of an app that wants your attention. It gives you
points for the time your phone lies untouched. The further away the phone is,
the more points. And you can compete with friends over who leaves it alone the
most.

## Why does it exist?

Because the phone has become a guest that never goes home. It sits on the table
at dinner, it comes to bed, it interrupts conversations, and it takes the small
pauses where your mind would otherwise wander.

Free Time is an attempt to turn that around: to make presence the thing that
gets rewarded, and to make the screen a little less invasive in everyday life.
Not with bans, but with a small, friendly score.

## How does it count?

**Android:** a small counter runs in the background all the time. When the
screen locks or turns off, a session starts. When you unlock, it ends. No
tapping required.

**iPhone:** Apple does not allow that kind of background measurement. There you
tap "Put the phone down" when you put it down and "Stop" when you pick it up.
The app then checks whether the phone actually lay still and whether it was
used in the meantime.

## How are points awarded?

You get 1 point per minute the phone lies there, multiplied by how "gone" it is:

| State                      | Multiplier |
|----------------------------|------------|
| Sound on                   | 1×         |
| Vibrate                    | 1.5×       |
| Silent                     | 2×         |
| Do Not Disturb / Focus     | 2.5×       |
| Airplane mode, Wi-Fi on    | 3×         |
| Airplane mode, Bluetooth on | 4×        |
| Airplane mode, all radios off | 5×      |
| Turned off                 | 10×        |
| Restart                    | +50 points |
| Screen on, but locked      | ×0.5       |
| In a pocket / moving       | ×0.5       |

Multipliers stack, so silent in a pocket is 2 × 0.5 = 1×.

Examples: an hour on silent on the table is 120 points. An hour in airplane
mode with all radios off is 300. A night turned off is about 4,800.

## What is the daily goal?

The daily goal is yours. The default is 600 points, which equals five hours on
silent or two hours in airplane mode. You can change it under "More"
in the app. The goal only affects the ring on the front page, not the standings
among friends.

## Can you cheat?

Yes, if you want to. You can leave the phone at home and go to work. But then
you actually were without your phone, and that is the whole point.

The app uses the phone's sensors to see whether it lay still and whether the
screen was used, and gives fewer points when it cannot confirm it. But this is
an app between friends, not a court.

## Why is iPhone different from Android?

Apple does not let apps read the silent switch, airplane mode, or whether the
phone is locked, and apps may not run in the background for hours. So on iPhone
you start and stop sessions yourself and tell the app whether it was on silent
or in airplane mode. Android gives access to all of it, so there it is measured
automatically.

## What data does the app store?

Only what is needed: when a session started and ended, which state the phone
was in (sound, silent, airplane, off), whether it lay still, and whether the
screen was on.

The app does not see which apps you use, who you message, or where you are.
Your friends can see your weekly points and total time without phone, not the
individual sessions.

## Why does the app ask for permissions?

**Android:** "Run in background" so the counter is not killed by battery
optimisation, and "Notifications" because Android requires a visible
notification for background services.

**iPhone:** both are optional. "Focus" to give a bonus for Do Not Disturb, and
"Screen Time" to verify that the phone was not used during a session. Everything
is read on the phone and never shared; change your mind under More → Permissions.

## Does it use a lot of battery?

No. The counter only listens for system events (screen, sound profile, airplane
mode) and uses the phone's low-power motion sensor. It does not measure
continuously.

## What is the plan going forward?

Groups and challenges ("no screen before 9"), streaks, a home screen widget,
and a web version of the standings. Suggestions are welcome.

## Who is behind it?

Free Time is a small, independent project with no ads and no selling of data.
Write to **freetime@rassta.dk** with questions, bugs or ideas.
