# iOS-opsætning (Mac med Xcode)

Projektet er oprettet på Linux, så iOS-delen er kun verificeret som kode, ikke
bygget. Gør følgende på Mac'en første gang:

```sh
git clone <repo> && cd free-time
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

## 1. App Group (deler state mellem app og Screen Time-extension)

Runner-target → Signing & Capabilities → `+ Capability` → **App Groups** →
tilføj `group.co.componental.freetime`.

## 2. Family Controls (Screen Time-API)

Runner-target → `+ Capability` → **Family Controls**.

Til udvikling og TestFlight-intern test virker det med det samme.
Til App Store skal entitlementet "Family Controls (Distribution)" ansøges:
<https://developer.apple.com/contact/request/family-controls-distribution>.

## 3. DeviceActivity Monitor-extension

File → New → Target → **Device Activity Monitor Extension**.

- Product name: `FreeTimeMonitor`
- Bundle id: `co.componental.freeTime.FreeTimeMonitor`
- Slet den genererede Swift-fil og træk `ios/FreeTimeMonitor/DeviceActivityMonitorExtension.swift`
  ind i target'et i stedet.
- Giv extension-target'et samme **App Groups**-capability som Runner.
- Extension-target'et skal også have **Family Controls**.

## 4. Tilladelser

`Info.plist` har allerede `NSMotionUsageDescription` og
`NSFocusStatusUsageDescription`. Appen beder om dem ved første åbning.

## 5. Magic link

URL-scheme `co.componental.freetime://login` er sat i `Info.plist`.
Tilføj samme URL under Supabase → Authentication → URL Configuration →
Redirect URLs.

## Hvad iOS-laget gør

| Signal          | Kilde                                          |
|-----------------|------------------------------------------------|
| Lå stille       | `CMMotionActivityManager.queryActivityStarting` |
| Blev brugt      | DeviceActivity-event (1 min brug af en hvilken som helst app) |
| Fokus           | `INFocusStatusCenter`                          |
| Genstart/slukket| `sysctl KERN_BOOTTIME` vs. sidste heartbeat    |
| Lydløs / fly    | Selvrapporteret i appen (ikke muligt at måle)  |
