# iOS-opsætning (Mac med Xcode)

Værktøjer er pinnet i `.mise.toml` (Flutter 3.47.7, Temurin 17). Homebrews
Flutter-cask er ældre og kan ikke bygge projektet, så brug mise:

```sh
brew install mise            # én gang
git clone <repo> && cd free-time
mise trust && mise install
mise exec -- flutter pub get
ios/scripts/setup_targets.sh
mise exec -- flutter build ios --simulator --debug
```

## Hvad `ios/scripts/setup_targets.sh` gør

Projektet blev oprettet på Linux, så Swift-filerne lå i repoet uden at
indgå i noget target. Scriptet (xcodeproj-gem'en fra Homebrews CocoaPods)
retter `Runner.xcodeproj` og kan køres igen uden at lave dubletter:

- `Runner/FreeTimeBridge.swift` kompileres med i Runner.
- `Runner/Runner.entitlements` og `FreeTimeMonitor/FreeTimeMonitor.entitlements`
  med App Group `group.co.componental.freetime` og Family Controls.
- Target `FreeTimeMonitor` (Device Activity Monitor-extension, bundle id
  `co.componental.freeTime.FreeTimeMonitor`) med samme Flutter-xcconfigs som
  Runner, så version/build-nummer følger appen. Indlejres i Runner.app/PlugIns.
- Team `XFQR9ZD5A3` og automatic signing på alle targets.

Det der *ikke* er scriptet, er at Xcode skal registrere App Group og Family
Controls på de to App ID'er i developer-portalen. Det sker automatisk første
gang man bygger til enhed med automatic signing — men kun hvis kontoen er
logget ind i Xcode og den nyeste Program License Agreement er accepteret på
<https://developer.apple.com/account>. Ellers fejler signeringen med
«Provisioning profile … doesn't include the App Groups capability».

## Verificeret 14/10-2026

- Simulator-build (iPhone 17, iOS 26.5, Xcode 26.6) bygger og starter; appen
  beder om Fokus-tilladelse via den native bridge.
- `FreeTimeMonitor.appex` ligger i `Runner.app/PlugIns` med version 0.1.0 (1).
- Enheds-build (`flutter build ios --debug`) signerer; `codesign -d --entitlements`
  viser Family Controls + App Group på både Runner.app og FreeTimeMonitor.appex.
  Krævede først PLA-accept på developer-kontoen (se ovenfor).
- Installeret på iPhone 14 Pro Max (iOS 26.6) via `xcrun devicectl device install app`
  + `process launch`. **Profile-build, ikke Debug** — en Debug-build kan ikke
  startes fra hjemmeskærmen («Flutter apps can only be launched from Flutter
  tooling»). Profile/Debug giver desuden en «lokale netværk»-prompt fra Flutters
  værktøj, som ikke findes i Release.
- Skærmtid-prompten (Apples tekst) og Fokus-prompten kom frem og virkede.
- `DeviceActivityEvent` i SDK'en har ikke `includesAllActivity:` som
  init-argument (det er en read-only property). Tomme token-sæt betyder «al
  aktivitet»; på iOS ≥ 17.4 bruges `includesPastActivity: false`. Ikke testet på
  enhed endnu.

## Family Controls i App Store

Til udvikling og TestFlight-intern test virker entitlementet med det samme.
Til App Store skal "Family Controls (Distribution)" ansøges:
<https://developer.apple.com/contact/request/family-controls-distribution>.

## Tilladelser

Begge valgfri, og de bedes om én ad gangen fra «Sådan måler vi»-skærmen
(`lib/ui/measure_intro_screen.dart`) før første session — aldrig ved start.
Bevægelse & fitness blev droppet 14/10-2026. `Info.plist` har kun
`NSFocusStatusUsageDescription`; Skærmtid-prompten er Apples egen tekst og kan
ikke ændres.

## Magic link

URL-scheme `co.componental.freetime://login` er sat i `Info.plist`.
Tilføj samme URL under Supabase → Authentication → URL Configuration →
Redirect URLs.

## Hvad iOS-laget gør

| Signal          | Kilde                                          |
|-----------------|------------------------------------------------|
| Blev brugt      | DeviceActivity-event (1 min brug af en hvilken som helst app) — valgfri; uden = uverificeret |
| Fokus           | `INFocusStatusCenter`                          |
| Genstart/slukket| `sysctl KERN_BOOTTIME` vs. sidste heartbeat    |
| Lydløs / fly    | Selvrapporteret i appen (ikke muligt at måle)  |
