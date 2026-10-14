// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appName => 'Free Time';

  @override
  String get tagline => 'Appen, der belønner dig for ikke at bruge den.';

  @override
  String get offline => 'offline';

  @override
  String get navToday => 'I dag';

  @override
  String get navWeek => 'Ugen';

  @override
  String get navFriends => 'Venner';

  @override
  String get navMore => 'Mere';

  @override
  String get greetingNight => 'God nat';

  @override
  String get greetingMorning => 'God morgen';

  @override
  String get greetingDay => 'God dag';

  @override
  String get greetingEvening => 'God aften';

  @override
  String get pointsToday => 'point i dag';

  @override
  String timeWithoutPhone(String time) {
    return '$time uden telefon';
  }

  @override
  String get goalReached => 'Dagens mål nået';

  @override
  String goalLabel(int goal) {
    return 'Mål: $goal point';
  }

  @override
  String get trackingOn => 'Tæller automatisk';

  @override
  String get trackingOff => 'Tælleren kører ikke';

  @override
  String get trackingHint =>
      'Når skærmen er låst. Skærm tændt giver halve point.';

  @override
  String get howIsPhoneLying => 'Hvordan ligger telefonen?';

  @override
  String stopWithTime(String time) {
    return 'Stop  ·  $time';
  }

  @override
  String get putPhoneDown => 'Læg telefonen fra dig';

  @override
  String get today => 'I dag';

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessioner',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get noSessionsTitle => 'Ingen sessioner endnu';

  @override
  String get noSessionsAndroid =>
      'Lås telefonen og læg den fra dig. Resten sker af sig selv.';

  @override
  String get noSessionsIos => 'Tryk på knappen, og læg telefonen fra dig.';

  @override
  String get flagScreenOn => 'skærm tændt';

  @override
  String get flagMoving => 'i bevægelse';

  @override
  String get flagReboot => 'genstart';

  @override
  String get modeNormal => 'Lyd';

  @override
  String get modeVibrate => 'Vibrer';

  @override
  String get modeSilent => 'Lydløs';

  @override
  String get modeDnd => 'Forstyr ikke';

  @override
  String get modeAirplane => 'Flytilstand';

  @override
  String get modePoweredOff => 'Slukket';

  @override
  String get modeShortNormal => 'Lyd';

  @override
  String get modeShortSilent => 'Lydløs';

  @override
  String get modeShortAirplane => 'Fly';

  @override
  String get weekTitle => 'Denne uge';

  @override
  String get weekSubtitle => 'Ugens stilling blandt dine venner';

  @override
  String get weekError => 'Kunne ikke hente stillingen.';

  @override
  String get weekAddFriendsHint =>
      'Tilføj venner under \"Venner\" for at konkurrere.';

  @override
  String pointsShort(int points) {
    return '$points pt';
  }

  @override
  String hoursMinutesWithoutPhone(int hours, int minutes) {
    return '${hours}t ${minutes}m uden telefon';
  }

  @override
  String get meOffline => 'dig (offline)';

  @override
  String get friendsTitle => 'Venner';

  @override
  String get friendsSubtitle =>
      'Inviter venner og se, hvem der lægger telefonen mest.';

  @override
  String get friendsOfflineSubtitle => 'Offline-tilstand';

  @override
  String get friendsOfflineBody =>
      'Appen er bygget uden backend. Venner og leaderboard kommer, når Supabase er koblet på.';

  @override
  String get yourUsernameHint => 'Dit brugernavn. Del det med venner.';

  @override
  String get addFriend => 'Tilføj ven';

  @override
  String get usernameHint => 'brugernavn';

  @override
  String requestSent(String name) {
    return 'Anmodning sendt til $name.';
  }

  @override
  String userNotFound(String name) {
    return 'Fandt ingen bruger med navnet \"$name\".';
  }

  @override
  String get requests => 'Anmodninger';

  @override
  String get accept => 'Accepter';

  @override
  String get moreTitle => 'Mere';

  @override
  String get moreSubtitle => 'Indstillinger, spørgsmål og kontakt';

  @override
  String get dailyGoal => 'Dagsmål';

  @override
  String get pointsPerDay => 'point om dagen';

  @override
  String goalEquivalent(String silent, String airplane) {
    return 'Svarer til $silent lydløs eller $airplane i flytilstand.';
  }

  @override
  String hoursShort(String hours) {
    return '$hours t';
  }

  @override
  String get other => 'Andet';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get pointsUnit => 'point';

  @override
  String get language => 'Sprog';

  @override
  String get languageSystem => 'System';

  @override
  String get faqTitle => 'Spørgsmål og svar';

  @override
  String get contact => 'Kontakt';

  @override
  String get tapToCopy => 'Tryk for at kopiere';

  @override
  String get emailCopied => 'E-mail kopieret';

  @override
  String get signOut => 'Log ud';

  @override
  String get footer => 'Free Time · ingen reklamer, ingen datasalg';

  @override
  String get authSubtitle =>
      'Appen, der belønner dig for ikke at bruge den.\nPoint for at lade telefonen ligge.';

  @override
  String get emailHint => 'din@mail.dk';

  @override
  String get sendLoginLink => 'Send login-link';

  @override
  String get noPasswordHint => 'Ingen adgangskode. Du får et link på mail.';

  @override
  String linkSent(String email) {
    return 'Vi har sendt et link til $email. Åbn det på telefonen for at logge ind.';
  }

  @override
  String get authError => 'Kunne ikke sende link. Tjek adressen og prøv igen.';

  @override
  String get chooseUsername => 'Vælg brugernavn';

  @override
  String get chooseUsernameHint => 'Det er sådan, dine venner finder dig.';

  @override
  String get usernameTaken =>
      'Brugernavn er optaget eller ugyldigt (a-z, 0-9, _, 3-20 tegn).';

  @override
  String get faq1Q => 'Hvad er Free Time?';

  @override
  String get faq1A =>
      'Free Time er det modsatte af en app, der vil have din opmærksomhed. Den giver dig point for den tid, din telefon ligger uberørt. Jo mere \"væk\" telefonen er, jo flere point. Og du kan konkurrere med venner om, hvem der lægger den mest.';

  @override
  String get faq2Q => 'Hvorfor findes den?';

  @override
  String get faq2A =>
      'Fordi telefonen er blevet en gæst, der aldrig går hjem. Den ligger på bordet til middagen, den er med i sengen, den afbryder samtaler, og den tager de små pauser, hvor tankerne ellers ville vandre. Free Time er et forsøg på at vende det om: at gøre tilstedeværelse til det, der belønnes, og gøre skærmen lidt mindre invaderende i hverdagen. Ikke med forbud, men med et lille, venligt regnskab.';

  @override
  String get faq3Q => 'Hvordan tæller den?';

  @override
  String get faq3A =>
      'På Android kører en lille tæller i baggrunden hele tiden. Når skærmen låses eller slukkes, starter en session. Når du låser op, slutter den. Det kræver ingen tryk.\n\nPå iPhone tillader Apple ikke den slags baggrundsmåling. Der trykker du \"Læg telefonen fra dig\", når du lægger den, og \"Stop\", når du tager den igen. Appen tjekker bagefter, om telefonen faktisk lå stille, og om den blev brugt imens.';

  @override
  String get faq4Q => 'Hvordan fordeles pointene?';

  @override
  String get faq4A =>
      'Du får 1 point pr. minut, telefonen ligger. Det ganges med en faktor for, hvor \"væk\" den er:\n\n•  Lyd på: 1×\n•  Vibrer: 1,5×\n•  Lydløs: 2×\n•  Forstyr ikke / Fokus: 2,5×\n•  Flytilstand: 4×\n•  Slukket: 6×\n•  Genstart: 50 point oveni\n\nLigger telefonen med skærmen tændt (men låst), halveres pointene. Bærer du den rundt i lommen, halveres de også. Faktorerne ganges sammen, så lydløs i lommen giver 2 × 0,5 = 1×.\n\nEksempel: en time lydløs på bordet giver 120 point. En time i flytilstand giver 240. En nat slukket giver omkring 2.900.';

  @override
  String get faq5Q => 'Hvad er dagsmålet?';

  @override
  String get faq5A =>
      'Dagsmålet er dit eget. Standard er 600 point, hvilket svarer til fem timer lydløs eller to en halv time i flytilstand. Du kan ændre det under \"Mere\". Målet påvirker kun ringen på forsiden, ikke stillingen blandt venner.';

  @override
  String get faq6Q => 'Kan man snyde?';

  @override
  String get faq6A =>
      'Ja, hvis man vil. Man kan lægge telefonen hjemme og gå på arbejde. Men så har man jo faktisk været uden telefon, og det er hele pointen. Appen bruger telefonens sensorer til at se, om den lå stille, og om skærmen blev brugt, og giver færre point, når den ikke kan bekræfte det. Men det er en app mellem venner, ikke en domstol.';

  @override
  String get faq7Q => 'Hvorfor er iPhone anderledes end Android?';

  @override
  String get faq7A =>
      'Apple lader ikke apps læse lydløs-knappen, flytilstand eller om telefonen er låst, og apps må ikke køre i baggrunden i timevis. Derfor starter og stopper du sessioner selv på iPhone og fortæller selv, om den var på lydløs eller i flytilstand. Android giver adgang til det hele, så der måles det automatisk.';

  @override
  String get faq8Q => 'Hvilke data gemmer appen?';

  @override
  String get faq8A =>
      'Kun det, der skal til: hvornår en session startede og sluttede, hvilken tilstand telefonen var i (lyd, lydløs, fly, slukket), om den lå stille, og om skærmen var tændt. Appen ser ikke, hvilke apps du bruger, hvem du skriver med, eller hvor du er. Dine venner kan se dine ugepoint og din samlede tid uden telefon, ikke de enkelte sessioner.';

  @override
  String get faq9Q => 'Hvorfor beder appen om tilladelser?';

  @override
  String get faq9A =>
      'På Android: \"Kør i baggrunden\" så tælleren ikke bliver slået ihjel af batterioptimering, og \"Notifikationer\" fordi Android kræver en synlig notifikation for baggrundstjenester. På iPhone: \"Bevægelse\" for at se om telefonen lå stille, \"Fokus\" for at give bonus for Forstyr ikke, og \"Skærmtid\" for at opdage om telefonen blev brugt under en session.';

  @override
  String get faq10Q => 'Bruger den meget batteri?';

  @override
  String get faq10A =>
      'Nej. Tælleren lytter kun efter systemhændelser (skærm, lydprofil, flytilstand) og bruger telefonens lavstrøms-bevægelsessensor. Den måler ikke løbende.';

  @override
  String get faq11Q => 'Hvad er planen fremad?';

  @override
  String get faq11A =>
      'Grupper og udfordringer (\"ingen skærm før kl. 9\"), streaks, en widget til hjemmeskærmen, og en web-version af stillingen. Forslag er velkomne.';

  @override
  String get faq12Q => 'Hvem står bag, og hvordan kontakter jeg jer?';

  @override
  String faq12A(String email) {
    return 'Free Time er et lille, uafhængigt projekt uden reklamer og uden salg af data. Skriv til $email med spørgsmål, fejl eller idéer.';
  }
}
