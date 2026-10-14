# Free Time

Point for at lade telefonen ligge. Jo mere "væk" den er, jo flere point.
Lydløs > vibrer > lyd. Flytilstand giver meget. Slukket giver mest. Genstart
giver bonus. Konkurrer med venner uge for uge.

Scope og pointmodel: [docs/scope.md](docs/scope.md). Spørgsmål og svar: [docs/FAQ.md](docs/FAQ.md).

## Stack

- **Flutter** (Dart) – UI og delt logik, `lib/`
- **Kotlin** – Android-målelag (foreground service, shutdown/boot), `android/app/src/main/kotlin/`
- **Swift** – iOS-målelag (CoreMotion, Screen Time, Focus, boot-tid), `ios/Runner/FreeTimeBridge.swift`
- **Supabase** – auth, Postgres, pointberegning, venner, leaderboard, `supabase/migrations/`

## Kom i gang

### Linux (Android)

Toolchain via mise (`.mise.toml` i repoet sætter Flutter, Java og `ANDROID_HOME`):

```sh
mise install
flutter doctor
flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_KEY=<publishable-key>
```

Android SDK ligger i `~/Android/Sdk` (cmdline-tools, platform-tools, API 36).

### Mac (iOS)

Se [docs/ios-setup.md](docs/ios-setup.md). Kræver App Group, Family Controls og
en DeviceActivity-extension oprettet i Xcode.

### Supabase

```sh
supabase init          # første gang, hvis du bruger CLI'en
supabase link --project-ref <ref>
supabase db push       # kører supabase/migrations/0001_init.sql
```

Eller kopiér SQL'en ind i SQL Editor i dashboardet.

Under Authentication → URL Configuration tilføjes redirect-URL'en
`co.componental.freetime://login`.

## Arkitektur i korte træk

1. Brugeren trykker "Læg telefonen fra dig". Native-laget starter en session.
2. Android: en foreground service overvåger bevægelse, skærm, lydprofil, DND og
   fly, og deler sessionen op i segmenter når tilstanden skifter.
   iOS: sessionen gemmes, og ved stop tjekkes bevægelseshistorik og Screen
   Time-events bagud.
3. Shutdown/boot bliver til `powered_off`- eller `reboot`-sessioner.
4. Færdige sessioner lander i en lokal kø og uploades til Supabase.
5. Postgres-triggeren `sessions_set_points` beregner point ud fra
   `scoring_rules`. Reglerne kan ændres uden app-opdatering.
6. `friend_leaderboard()` giver ugens stilling blandt accepterede venner.
