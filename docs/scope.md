# Free Time – scope

Anti-screen-time app. Du får point for *ikke* at bruge din telefon.
Jo mere "væk" telefonen er, jo flere point.

## Platforme

Android og iOS fra én Flutter-kodebase. Målelaget er native:

| Signal                         | Android                   | iOS                                   |
|--------------------------------|---------------------------|---------------------------------------|
| Ligger stille / i bevægelse    | Live (accelerometer)      | Nej (Bevægelse-tilladelsen droppet 14/10-2026) |
| Lomme vs. bord                 | Nærhed + lys (fase 2)     | Nej                                   |
| Telefonen blev brugt           | Live (skærm tændt/låst op)| Screen Time / DeviceActivity-events   |
| Lyd / vibrer / lydløs          | AudioManager              | Nej → selvrapporteret i sessionen     |
| Forstyr ikke / Fokus           | NotificationManager       | Focus status (med tilladelse)         |
| Flytilstand                    | Settings.Global           | Nej → selvrapporteret                 |
| Slukket-tid og genstart        | ACTION_SHUTDOWN + BOOT    | Boot-tid (sysctl) + sidste heartbeat  |

## Produktmodel

**Android tæller hele tiden.** En altid-kørende service åbner et segment, så
snart telefonen er låst eller skærmen slukkes, og lukker det ved oplåsning.
**iOS kører sessioner**, som brugeren starter og stopper manuelt (OS-begrænsning). Klienten deler en session op hver gang tilstanden ændrer
sig (fx lydløs → fly), så én session har præcis én `mode`.

Sessioner uploades til Supabase. **Serveren beregner point** ud fra
`scoring_rules`, så regler kan justeres uden app-opdatering.

## Point

Basis: 1 point pr. minut stille, ganget med faktor for tilstanden.

| Tilstand        | Faktor | Kilde                                  |
|-----------------|--------|----------------------------------------|
| Lyd             | 1,0    | Android: målt. iOS: default            |
| Vibrer          | 1,5    | Android: målt. iOS: selvrapporteret    |
| Lydløs          | 2,0    | Android: målt. iOS: selvrapporteret    |
| Forstyr ikke    | 2,5    | Begge: målt                            |
| Flytilstand     | 4,0    | Android: målt. iOS: selvrapporteret    |
| Slukket         | 6,0    | Begge: udledt af shutdown/boot         |
| Genstart        | +50    | Begge                                  |
| Skærm tændt, låst | ×0,5 | Android: målt                          |
| I bevægelse / lomme | ×0,5 | Android: målt live. iOS: nej           |

Faktorerne ganges sammen: lydløs + skærm tændt + i bevægelse = 2,0 × 0,5 × 0,5.
Uverificeret (bevægelse, eller iOS kunne ikke bekræfte) er den milde snyd-sikring.

## Socialt

- Konto (Supabase Auth, e-mail magic link + Apple/Google senere).
- Venner via brugernavn, anmodning/accept.
- Ugentligt leaderboard blandt venner (`friend_leaderboard()`).
- Fase 2: grupper, udfordringer ("ingen skærm før kl. 9"), streaks.

## MVP

1. Flutter-app: login, start/stop session, "i dag"-skærm, venner, leaderboard.
2. Android: foreground service der verificerer stilhed, lydprofil, fly, DND,
   shutdown/boot.
3. iOS: verificering via DeviceActivity-events (valgfri), Focus (valgfri),
   boot-tid. Selvrapportering af lydløs/fly. Tilladelser bedes om fra
   «Sådan måler vi»-skærmen før første session, aldrig ved start.
4. Supabase: `supabase/migrations/0001_init.sql`.

## Fase 2

Lomme-detektion via nærhedssensor, widgets, Live Activity på
iOS, grupper/udfordringer, Wear OS.

## Kendte forbehold

- iOS Screen Time-API kræver "Family Controls (Distribution)"-entitlement fra
  Apple til App Store. Udvikling og TestFlight-intern test kan ske uden.
- Android batterioptimering kan dræbe servicen; appen beder om undtagelse.
- Telefonen efterladt derhjemme giver maksimale point. Det er accepteret.
