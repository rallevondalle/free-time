// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Free Time';

  @override
  String get tagline => 'Punkte dafür, das Handy liegen zu lassen.';

  @override
  String get offline => 'offline';

  @override
  String get navToday => 'Heute';

  @override
  String get navWeek => 'Woche';

  @override
  String get navFriends => 'Freunde';

  @override
  String get navMore => 'Mehr';

  @override
  String get greetingNight => 'Gute Nacht';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingDay => 'Hallo';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get pointsToday => 'Punkte heute';

  @override
  String timeWithoutPhone(String time) {
    return '$time ohne Handy';
  }

  @override
  String get goalReached => 'Tagesziel erreicht';

  @override
  String goalLabel(int goal) {
    return 'Ziel: $goal Punkte';
  }

  @override
  String get trackingOn => 'Zählt automatisch';

  @override
  String get trackingOff => 'Der Zähler läuft nicht';

  @override
  String get trackingHint =>
      'Immer wenn der Bildschirm gesperrt ist. Bildschirm an gibt halbe Punkte.';

  @override
  String get howIsPhoneLying => 'Wie liegt das Handy?';

  @override
  String stopWithTime(String time) {
    return 'Stopp  ·  $time';
  }

  @override
  String get putPhoneDown => 'Handy weglegen';

  @override
  String get today => 'Heute';

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sitzungen',
      one: '1 Sitzung',
    );
    return '$_temp0';
  }

  @override
  String get noSessionsTitle => 'Noch keine Sitzungen';

  @override
  String get noSessionsAndroid =>
      'Sperre dein Handy und leg es weg. Der Rest passiert von selbst.';

  @override
  String get noSessionsIos => 'Tippe auf den Knopf und leg das Handy weg.';

  @override
  String get flagScreenOn => 'Bildschirm an';

  @override
  String get flagMoving => 'in Bewegung';

  @override
  String get flagReboot => 'Neustart';

  @override
  String get modeNormal => 'Ton';

  @override
  String get modeVibrate => 'Vibration';

  @override
  String get modeSilent => 'Lautlos';

  @override
  String get modeDnd => 'Nicht stören';

  @override
  String get modeAirplane => 'Flugmodus';

  @override
  String get modePoweredOff => 'Aus';

  @override
  String get modeShortNormal => 'Ton';

  @override
  String get modeShortSilent => 'Lautlos';

  @override
  String get modeShortAirplane => 'Flug';

  @override
  String get weekTitle => 'Diese Woche';

  @override
  String get weekSubtitle => 'Der Wochenstand unter deinen Freunden';

  @override
  String get weekError => 'Rangliste konnte nicht geladen werden.';

  @override
  String get weekAddFriendsHint =>
      'Füge unter „Freunde“ Freunde hinzu, um mitzumachen.';

  @override
  String pointsShort(int points) {
    return '$points Pkt.';
  }

  @override
  String hoursMinutesWithoutPhone(int hours, int minutes) {
    return '$hours Std. $minutes Min. ohne Handy';
  }

  @override
  String get meOffline => 'du (offline)';

  @override
  String get friendsTitle => 'Freunde';

  @override
  String get friendsSubtitle =>
      'Lade Freunde ein und sieh, wer sein Handy am meisten liegen lässt.';

  @override
  String get friendsOfflineSubtitle => 'Offline-Modus';

  @override
  String get friendsOfflineBody =>
      'Die App wurde ohne Backend gebaut. Freunde und Rangliste kommen, sobald Supabase verbunden ist.';

  @override
  String get yourUsernameHint => 'Dein Benutzername. Teile ihn mit Freunden.';

  @override
  String get addFriend => 'Freund hinzufügen';

  @override
  String get usernameHint => 'benutzername';

  @override
  String requestSent(String name) {
    return 'Anfrage an $name gesendet.';
  }

  @override
  String userNotFound(String name) {
    return 'Kein Nutzer namens „$name“.';
  }

  @override
  String get requests => 'Anfragen';

  @override
  String get accept => 'Annehmen';

  @override
  String get moreTitle => 'Mehr';

  @override
  String get moreSubtitle => 'Einstellungen, Fragen und Kontakt';

  @override
  String get dailyGoal => 'Tagesziel';

  @override
  String get pointsPerDay => 'Punkte pro Tag';

  @override
  String goalEquivalent(String silent, String airplane) {
    return 'Entspricht $silent lautlos oder $airplane im Flugmodus.';
  }

  @override
  String hoursShort(String hours) {
    return '$hours Std.';
  }

  @override
  String get other => 'Andere';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get pointsUnit => 'Punkte';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get faqTitle => 'Fragen und Antworten';

  @override
  String get contact => 'Kontakt';

  @override
  String get tapToCopy => 'Tippen zum Kopieren';

  @override
  String get emailCopied => 'E-Mail kopiert';

  @override
  String get signOut => 'Abmelden';

  @override
  String get footer => 'Free Time · keine Werbung, kein Datenverkauf';

  @override
  String get authSubtitle =>
      'Punkte dafür, das Handy liegen zu lassen.\nJe weiter weg, desto mehr Punkte.';

  @override
  String get emailHint => 'du@beispiel.de';

  @override
  String get sendLoginLink => 'Login-Link senden';

  @override
  String get noPasswordHint =>
      'Kein Passwort. Du bekommst einen Link per E-Mail.';

  @override
  String linkSent(String email) {
    return 'Wir haben einen Link an $email gesendet. Öffne ihn auf deinem Handy, um dich anzumelden.';
  }

  @override
  String get authError =>
      'Link konnte nicht gesendet werden. Prüfe die Adresse und versuche es erneut.';

  @override
  String get chooseUsername => 'Benutzernamen wählen';

  @override
  String get chooseUsernameHint => 'So finden dich deine Freunde.';

  @override
  String get usernameTaken =>
      'Benutzername vergeben oder ungültig (a-z, 0-9, _, 3–20 Zeichen).';

  @override
  String get faq1Q => 'Was ist Free Time?';

  @override
  String get faq1A =>
      'Free Time ist das Gegenteil einer App, die deine Aufmerksamkeit will. Sie gibt dir Punkte für die Zeit, in der dein Handy unberührt liegt. Je weiter weg das Handy ist, desto mehr Punkte. Und du kannst mit Freunden wetteifern, wer es am meisten liegen lässt.';

  @override
  String get faq2Q => 'Warum gibt es sie?';

  @override
  String get faq2A =>
      'Weil das Handy zu einem Gast geworden ist, der nie nach Hause geht. Es liegt beim Abendessen auf dem Tisch, es kommt mit ins Bett, es unterbricht Gespräche, und es nimmt sich die kleinen Pausen, in denen die Gedanken sonst wandern würden. Free Time ist ein Versuch, das umzudrehen: Präsenz zu dem zu machen, was belohnt wird, und den Bildschirm im Alltag etwas weniger aufdringlich zu machen. Nicht mit Verboten, sondern mit einem kleinen, freundlichen Punktestand.';

  @override
  String get faq3Q => 'Wie zählt sie?';

  @override
  String get faq3A =>
      'Auf Android läuft ständig ein kleiner Zähler im Hintergrund. Wenn der Bildschirm gesperrt oder ausgeschaltet wird, beginnt eine Sitzung. Wenn du entsperrst, endet sie. Kein Tippen nötig.\n\nAuf dem iPhone erlaubt Apple diese Art von Hintergrundmessung nicht. Dort tippst du auf „Handy weglegen“, wenn du es weglegst, und auf „Stopp“, wenn du es wieder nimmst. Die App prüft danach, ob das Handy wirklich still lag und ob es zwischendurch benutzt wurde.';

  @override
  String get faq4Q => 'Wie werden Punkte vergeben?';

  @override
  String get faq4A =>
      'Du bekommst 1 Punkt pro Minute, die das Handy liegt. Das wird mit einem Faktor dafür multipliziert, wie „weg“ es ist:\n\n•  Ton an: 1×\n•  Vibration: 1,5×\n•  Lautlos: 2×\n•  Nicht stören / Fokus: 2,5×\n•  Flugmodus: 4×\n•  Ausgeschaltet: 6×\n•  Neustart: 50 Punkte obendrauf\n\nLiegt das Handy mit eingeschaltetem (aber gesperrtem) Bildschirm, werden die Punkte halbiert. Trägst du es in der Tasche herum, ebenfalls. Faktoren multiplizieren sich, also ergibt lautlos in der Tasche 2 × 0,5 = 1×.\n\nBeispiel: eine Stunde lautlos auf dem Tisch sind 120 Punkte. Eine Stunde im Flugmodus sind 240. Eine Nacht ausgeschaltet sind etwa 2.900.';

  @override
  String get faq5Q => 'Was ist das Tagesziel?';

  @override
  String get faq5A =>
      'Das Tagesziel ist deins. Standard sind 600 Punkte, das entspricht fünf Stunden lautlos oder zweieinhalb Stunden im Flugmodus. Du kannst es unter „Mehr“ ändern. Das Ziel beeinflusst nur den Ring auf der Startseite, nicht die Rangliste unter Freunden.';

  @override
  String get faq6Q => 'Kann man schummeln?';

  @override
  String get faq6A =>
      'Ja, wenn man will. Man kann das Handy zu Hause lassen und zur Arbeit gehen. Aber dann war man tatsächlich ohne Handy, und genau darum geht es. Die App nutzt die Sensoren des Handys, um zu sehen, ob es still lag und ob der Bildschirm benutzt wurde, und gibt weniger Punkte, wenn sie das nicht bestätigen kann. Aber das ist eine App unter Freunden, kein Gericht.';

  @override
  String get faq7Q => 'Warum ist das iPhone anders als Android?';

  @override
  String get faq7A =>
      'Apple lässt Apps weder den Lautlos-Schalter noch den Flugmodus oder den Sperrzustand auslesen, und Apps dürfen nicht stundenlang im Hintergrund laufen. Deshalb startest und stoppst du Sitzungen auf dem iPhone selbst und gibst selbst an, ob es lautlos oder im Flugmodus war. Android gewährt Zugriff auf alles, daher wird dort automatisch gemessen.';

  @override
  String get faq8Q => 'Welche Daten speichert die App?';

  @override
  String get faq8A =>
      'Nur das Nötige: wann eine Sitzung begann und endete, in welchem Zustand das Handy war (Ton, lautlos, Flugmodus, aus), ob es still lag und ob der Bildschirm an war. Die App sieht nicht, welche Apps du nutzt, mit wem du schreibst oder wo du bist. Deine Freunde sehen deine Wochenpunkte und deine Gesamtzeit ohne Handy, nicht die einzelnen Sitzungen.';

  @override
  String get faq9Q => 'Warum fragt die App nach Berechtigungen?';

  @override
  String get faq9A =>
      'Auf Android: „Im Hintergrund ausführen“, damit der Zähler nicht von der Akkuoptimierung beendet wird, und „Benachrichtigungen“, weil Android für Hintergrunddienste eine sichtbare Benachrichtigung verlangt. Auf dem iPhone: „Bewegung“, um zu sehen, ob das Handy still lag, „Fokus“ für den Bonus bei Nicht stören, und „Bildschirmzeit“, um zu erkennen, ob das Handy während einer Sitzung benutzt wurde.';

  @override
  String get faq10Q => 'Verbraucht sie viel Akku?';

  @override
  String get faq10A =>
      'Nein. Der Zähler reagiert nur auf Systemereignisse (Bildschirm, Tonprofil, Flugmodus) und nutzt den stromsparenden Bewegungssensor des Handys. Er misst nicht dauerhaft.';

  @override
  String get faq11Q => 'Was ist der Plan für die Zukunft?';

  @override
  String get faq11A =>
      'Gruppen und Challenges („kein Bildschirm vor 9“), Serien, ein Widget für den Startbildschirm und eine Web-Version der Rangliste. Vorschläge sind willkommen.';

  @override
  String get faq12Q => 'Wer steckt dahinter, und wie erreiche ich euch?';

  @override
  String faq12A(String email) {
    return 'Free Time ist ein kleines, unabhängiges Projekt ohne Werbung und ohne Datenverkauf. Schreib an $email mit Fragen, Fehlern oder Ideen.';
  }
}
