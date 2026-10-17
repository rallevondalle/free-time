// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Free Time';

  @override
  String get tagline => 'De app die je beloont als je hem niet gebruikt.';

  @override
  String get offline => 'offline';

  @override
  String get navToday => 'Vandaag';

  @override
  String get navWeek => 'Week';

  @override
  String get navFriends => 'Vrienden';

  @override
  String get navMore => 'Meer';

  @override
  String get greetingNight => 'Goedenacht';

  @override
  String get greetingMorning => 'Goedemorgen';

  @override
  String get greetingDay => 'Hallo';

  @override
  String get greetingEvening => 'Goedenavond';

  @override
  String get pointsToday => 'punten vandaag';

  @override
  String timeWithoutPhone(String time) {
    return '$time zonder telefoon';
  }

  @override
  String get goalReached => 'Dagdoel gehaald';

  @override
  String goalLabel(int goal) {
    return 'Doel: $goal punten';
  }

  @override
  String get trackingOn => 'Telt automatisch';

  @override
  String get trackingOff => 'De teller draait niet';

  @override
  String get trackingHint =>
      'Zodra het scherm vergrendeld is. Scherm aan geeft halve punten.';

  @override
  String get howIsPhoneLying => 'Hoe ligt de telefoon?';

  @override
  String stopWithTime(String time) {
    return 'Stop  ·  $time';
  }

  @override
  String get putPhoneDown => 'Leg de telefoon weg';

  @override
  String get today => 'Vandaag';

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessies',
      one: '1 sessie',
    );
    return '$_temp0';
  }

  @override
  String get noSessionsTitle => 'Nog geen sessies';

  @override
  String get noSessionsAndroid =>
      'Vergrendel je telefoon en leg hem weg. De rest gaat vanzelf.';

  @override
  String get noSessionsIos => 'Tik op de knop en leg de telefoon weg.';

  @override
  String get flagScreenOn => 'scherm aan';

  @override
  String get flagMoving => 'in beweging';

  @override
  String get flagReboot => 'herstart';

  @override
  String get modeNormal => 'Geluid';

  @override
  String get modeVibrate => 'Trillen';

  @override
  String get modeSilent => 'Stil';

  @override
  String get modeDnd => 'Niet storen';

  @override
  String get modeAirplane => 'Vliegtuigmodus';

  @override
  String get modePoweredOff => 'Uit';

  @override
  String get modeShortNormal => 'Geluid';

  @override
  String get modeShortSilent => 'Stil';

  @override
  String get modeShortAirplane => 'Vliegtuig';

  @override
  String get weekTitle => 'Deze week';

  @override
  String get weekSubtitle => 'De weekstand onder je vrienden';

  @override
  String get weekError => 'Kon de stand niet laden.';

  @override
  String get weekAddFriendsHint =>
      'Voeg vrienden toe onder \"Vrienden\" om mee te doen.';

  @override
  String pointsShort(int points) {
    return '$points pt';
  }

  @override
  String hoursMinutesWithoutPhone(int hours, int minutes) {
    return '${hours}u ${minutes}m zonder telefoon';
  }

  @override
  String get meOffline => 'jij (offline)';

  @override
  String get friendsTitle => 'Vrienden';

  @override
  String get friendsSubtitle =>
      'Nodig vrienden uit en zie wie zijn telefoon het meest laat liggen.';

  @override
  String get friendsOfflineSubtitle => 'Offline-modus';

  @override
  String get friendsOfflineBody =>
      'De app is gebouwd zonder backend. Vrienden en de stand komen zodra Supabase is gekoppeld.';

  @override
  String get yourUsernameHint => 'Je gebruikersnaam. Deel hem met vrienden.';

  @override
  String get addFriend => 'Vriend toevoegen';

  @override
  String get usernameHint => 'gebruikersnaam';

  @override
  String requestSent(String name) {
    return 'Verzoek verstuurd naar $name.';
  }

  @override
  String userNotFound(String name) {
    return 'Geen gebruiker met de naam \"$name\".';
  }

  @override
  String get requests => 'Verzoeken';

  @override
  String get accept => 'Accepteren';

  @override
  String get moreTitle => 'Meer';

  @override
  String get moreSubtitle => 'Instellingen, vragen en contact';

  @override
  String get dailyGoal => 'Dagdoel';

  @override
  String get pointsPerDay => 'punten per dag';

  @override
  String goalEquivalent(String silent, String airplane) {
    return 'Staat gelijk aan $silent stil of $airplane in vliegtuigmodus.';
  }

  @override
  String hoursShort(String hours) {
    return '$hours u';
  }

  @override
  String get other => 'Anders';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get pointsUnit => 'punten';

  @override
  String get language => 'Taal';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get faqTitle => 'Vragen en antwoorden';

  @override
  String get contact => 'Contact';

  @override
  String get tapToCopy => 'Tik om te kopiëren';

  @override
  String get emailCopied => 'E-mail gekopieerd';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get footer => 'Free Time · geen advertenties, geen dataverkoop';

  @override
  String get authSubtitle =>
      'De app die je beloont als je hem niet gebruikt.\nPunten voor je telefoon laten liggen.';

  @override
  String get emailHint => 'jij@voorbeeld.nl';

  @override
  String get sendLoginLink => 'Code versturen';

  @override
  String get noPasswordHint =>
      'Geen wachtwoord. Je krijgt een 6-cijferige code per e-mail – lees hem waar je wilt, typ hem hier in.';

  @override
  String linkSent(String email) {
    return 'We hebben een code gestuurd naar $email.';
  }

  @override
  String get codeHint => '6-cijferige code';

  @override
  String get verifyCode => 'Inloggen';

  @override
  String get codeError =>
      'Verkeerde of verlopen code. Probeer opnieuw of vraag een nieuwe aan.';

  @override
  String get resendCode => 'Nieuwe code versturen';

  @override
  String get continueWithoutAccount => 'Doorgaan zonder account';

  @override
  String get withoutAccountHint =>
      'Punten blijven op deze telefoon. Geen vrienden of ranglijst. Je kunt later inloggen onder Meer.';

  @override
  String get signInLater => 'Inloggen of account aanmaken';

  @override
  String get signInLaterHint =>
      'Nodig voor vrienden en de weekranglijst. De sessies op deze telefoon gaan mee.';

  @override
  String get authError =>
      'Kon de link niet versturen. Controleer het adres en probeer opnieuw.';

  @override
  String get chooseUsername => 'Kies een gebruikersnaam';

  @override
  String get chooseUsernameHint => 'Zo vinden je vrienden je.';

  @override
  String get usernameTaken =>
      'Gebruikersnaam bezet of ongeldig (a-z, 0-9, _, 3-20 tekens).';

  @override
  String get faq1Q => 'Wat is Free Time?';

  @override
  String get faq1A =>
      'Free Time is het tegenovergestelde van een app die je aandacht wil. Hij geeft je punten voor de tijd dat je telefoon onaangeraakt ligt. Hoe verder weg de telefoon, hoe meer punten. En je kunt met vrienden strijden om wie hem het meest laat liggen.';

  @override
  String get faq2Q => 'Waarom bestaat hij?';

  @override
  String get faq2A =>
      'Omdat de telefoon een gast is geworden die nooit naar huis gaat. Hij ligt op tafel bij het eten, hij gaat mee naar bed, hij onderbreekt gesprekken, en hij pakt de kleine pauzes waarin je gedachten anders zouden dwalen. Free Time probeert dat om te draaien: aanwezigheid belonen, en het scherm in het dagelijks leven wat minder opdringerig maken. Niet met verboden, maar met een kleine, vriendelijke score.';

  @override
  String get faq3Q => 'Hoe telt hij?';

  @override
  String get faq3A =>
      'Op Android draait er altijd een kleine teller op de achtergrond. Als het scherm vergrendelt of uitgaat, begint een sessie. Als je ontgrendelt, eindigt die. Geen tikken nodig.\n\nOp de iPhone staat Apple dat soort achtergrondmeting niet toe. Daar tik je op \"Leg de telefoon weg\" als je hem weglegt en op \"Stop\" als je hem weer pakt. De app controleert daarna of de telefoon echt stil lag en of hij ondertussen gebruikt is.';

  @override
  String get faq4Q => 'Hoe worden punten toegekend?';

  @override
  String get faq4A =>
      'Je krijgt 1 punt per minuut dat de telefoon ligt. Dat wordt vermenigvuldigd met een factor voor hoe \"weg\" hij is:\n\n•  Geluid aan: 1×\n•  Trillen: 1,5×\n•  Stil: 2×\n•  Niet storen / Focus: 2,5×\n•  Vliegtuigmodus: 3× met wifi aan, 4× met bluetooth aan, 5× met alles uit\n•  Uitgeschakeld: 10×\n•  Herstart: 50 punten erbovenop\n\nBuiten vliegtuigmodus geeft elke radio die je uitzet (wifi, bluetooth, mobiele data) ×1,1 erbovenop, dus alle drie uit is ×1,33. Vliegtuigmodus met alles uit blijft het hoogste voor een telefoon die aanstaat.\n\nLigt de telefoon met het scherm aan (maar vergrendeld), dan worden de punten gehalveerd. Draag je hem in je zak, dan ook. Factoren stapelen, dus stil in je zak is 2 × 0,5 = 1×.\n\nVoorbeeld: een uur stil op tafel is 120 punten. Een uur stil met alle radio\'s uit is 160. Een uur in vliegtuigmodus met alles uit is 300. Een nacht uitgeschakeld is ongeveer 4.800.';

  @override
  String get faq5Q => 'Wat is het dagdoel?';

  @override
  String get faq5A =>
      'Het dagdoel is van jou. Standaard is 600 punten, wat gelijkstaat aan vijf uur stil of twee uur in vliegtuigmodus. Je kunt het wijzigen onder \"Meer\". Het doel beïnvloedt alleen de ring op de voorpagina, niet de stand onder vrienden.';

  @override
  String get faq6Q => 'Kun je valsspelen?';

  @override
  String get faq6A =>
      'Ja, als je wilt. Je kunt de telefoon thuislaten en naar je werk gaan. Maar dan was je ook echt zonder telefoon, en dat is precies het punt. De app gebruikt de sensoren van de telefoon om te zien of hij stil lag en of het scherm gebruikt is, en geeft minder punten als hij dat niet kan bevestigen. Maar dit is een app onder vrienden, geen rechtbank.';

  @override
  String get faq7Q => 'Waarom is de iPhone anders dan Android?';

  @override
  String get faq7A =>
      'Apple laat apps de stilknop, vliegtuigmodus of de vergrendelstatus niet uitlezen, en apps mogen niet urenlang op de achtergrond draaien. Op de iPhone start en stop je sessies dus zelf en geef je zelf aan of hij stil of in vliegtuigmodus stond. Android geeft toegang tot alles, dus daar wordt automatisch gemeten.';

  @override
  String get faq8Q => 'Welke gegevens bewaart de app?';

  @override
  String get faq8A =>
      'Alleen wat nodig is: wanneer een sessie begon en eindigde, in welke stand de telefoon stond (geluid, stil, vliegtuig, uit), of hij stil lag en of het scherm aan was. De app ziet niet welke apps je gebruikt, met wie je berichten uitwisselt of waar je bent. Je vrienden zien je weekpunten en je totale tijd zonder telefoon, niet de afzonderlijke sessies.';

  @override
  String get flagUnverified => 'niet geverifieerd';

  @override
  String get measureTitle => 'Zo meten we';

  @override
  String get measureIntro =>
      'Op de iPhone start en stop je zelf een sessie. Apple laat apps de stille schakelaar, de vliegtuigmodus en het vergrendelscherm niet lezen, dus dat deel vertel jij ons. Twee optionele toestemmingen maken de rest preciezer.';

  @override
  String get measureSessionTitle => 'Jij start en stopt';

  @override
  String get measureSessionBody =>
      'Tik op \"Telefoon wegleggen\" als je hem weglegt en op \"Stop\" als je hem weer pakt. Dat is de hele basis voor je punten.';

  @override
  String get measureFocusTitle => 'Focus';

  @override
  String get measureFocusBody =>
      'Niet storen geeft 2,5× punten. iOS vertelt de app maar één ja/nee: staat er een Focus aan. Niet welke, niet wie je berichten stuurt.';

  @override
  String get measureScreenTimeTitle => 'Schermtijd';

  @override
  String get measureScreenTimeBody =>
      'Maakt je sessies geverifieerd. iOS meldt de app als de telefoon tijdens een sessie langer dan een minuut gebruikt wordt. De app ziet nooit welke apps of hoe lang. Apples eigen melding noemt het beperken van apps – dat gebruikt Free Time niet.';

  @override
  String get measurePrivacy =>
      'Alles wordt op de telefoon gelezen en blijft daar. Het enige dat naar de server gaat: begin, einde, modus, hoe vaak de telefoon is opgepakt, en of de sessie geverifieerd was.';

  @override
  String get measureAllow => 'Toestaan';

  @override
  String get measureAllowed => 'Toegestaan';

  @override
  String get measureOptional => 'optioneel';

  @override
  String get measureContinue => 'Doorgaan';

  @override
  String get measureSkip => 'Doorgaan zonder';

  @override
  String get measurePermissions => 'Toestemmingen';

  @override
  String get modeShortVibrate => 'Trillen';

  @override
  String get factorTitle => 'Je factor op dit moment';

  @override
  String factorPerMinute(String factor) {
    return '$factor× punten per minuut';
  }

  @override
  String get factorUnverified => 'niet geverifieerd ×0,5';

  @override
  String get factorFocusOn => 'Focus staat aan';

  @override
  String get factorIosHint =>
      'Kies hoe de telefoon ligt — iOS kan het niet lezen.';

  @override
  String get factorVerified => 'geverifieerd';

  @override
  String get factorTapHint => 'Tik op een radio om die te wijzigen.';

  @override
  String get permHintTitle => 'Preciezere punten';

  @override
  String get permHintScreenTime =>
      'Schermtijd ontbreekt: elke sessie wordt gehalveerd.';

  @override
  String get permHintFocus => 'Focus ontbreekt: Niet storen telt niet 2,5×.';

  @override
  String get permHintDismiss => 'Verbergen';

  @override
  String get radioWifiOff => 'Wi-Fi uit';

  @override
  String get radioBluetoothOff => 'Bluetooth uit';

  @override
  String get radioWifiOn => 'Wi-Fi aan';

  @override
  String get radioBluetoothOn => 'Bluetooth aan';

  @override
  String get airplaneRadiosHint =>
      'In vliegtuigmodus: zet ook Wi-Fi en Bluetooth uit voor de volledige factor.';

  @override
  String get radioDataOff => 'Mobiele data uit';

  @override
  String get radioDataOn => 'Mobiele data aan';

  @override
  String get radiosHint =>
      'Zet wifi, bluetooth en mobiele data uit: elk ×1,1, alle drie ×1,33.';

  @override
  String get diagnostics => 'Diagnose';

  @override
  String get faq9Q => 'Waarom vraagt de app om toestemmingen?';

  @override
  String get faq9A =>
      'Op Android: \"Op de achtergrond uitvoeren\" zodat de teller niet door batterijoptimalisatie wordt gestopt, en \"Meldingen\" omdat Android een zichtbare melding vereist voor achtergronddiensten. Op de iPhone zijn beide toestemmingen optioneel: \"Focus\" voor de bonus bij Niet storen, en \"Schermtijd\" om te bevestigen dat de telefoon tijdens een sessie niet gebruikt is. Alles wordt op de telefoon gelezen en nooit gedeeld. Je kunt het altijd aanpassen onder Meer → Toestemmingen.';

  @override
  String get faq10Q => 'Gebruikt hij veel batterij?';

  @override
  String get faq10A =>
      'Nee. De teller luistert alleen naar systeemgebeurtenissen (scherm, geluidsprofiel, vliegtuigmodus) en gebruikt de zuinige bewegingssensor van de telefoon. Hij meet niet continu.';

  @override
  String get faq11Q => 'Wat is het plan voor de toekomst?';

  @override
  String get faq11A =>
      'Groepen en uitdagingen (\"geen scherm voor 9 uur\"), reeksen, een widget voor het startscherm en een webversie van de stand. Suggesties zijn welkom.';

  @override
  String get faq12Q => 'Wie zit erachter, en hoe neem ik contact op?';

  @override
  String faq12A(String email) {
    return 'Free Time is een klein, onafhankelijk project zonder advertenties en zonder dataverkoop. Schrijf naar $email met vragen, fouten of ideeën.';
  }

  @override
  String avg30Line(int points, int n) {
    return 'Gem. $points/dag, laatste $n dagen';
  }

  @override
  String get statsTitle => 'Statistieken';

  @override
  String statsSince(String date) {
    return 'Sinds $date';
  }

  @override
  String statsDaysTracked(int n) {
    return '$n hele dagen';
  }

  @override
  String get statsTotalPoints => 'Punten in totaal';

  @override
  String get statsAvgLifetime => 'Gemiddelde per dag, totaal';

  @override
  String statsAvg30(int n) {
    return 'Gemiddelde per dag, laatste $n dagen';
  }

  @override
  String get statsBestDays => 'Beste dagen';

  @override
  String get statsWorstDays => 'Slechtste dagen';

  @override
  String get statsEmpty =>
      'Statistieken beginnen morgen, als er een hele dag is om mee te rekenen.';

  @override
  String get statsToday => 'Vandaag tot nu toe';
}
