// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Free Time';

  @override
  String get tagline => 'L\'appli qui vous récompense de ne pas l\'utiliser.';

  @override
  String get offline => 'hors ligne';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navWeek => 'Semaine';

  @override
  String get navFriends => 'Amis';

  @override
  String get navMore => 'Plus';

  @override
  String get greetingNight => 'Bonne nuit';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingDay => 'Bonjour';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get pointsToday => 'points aujourd\'hui';

  @override
  String timeWithoutPhone(String time) {
    return '$time sans téléphone';
  }

  @override
  String get goalReached => 'Objectif du jour atteint';

  @override
  String goalLabel(int goal) {
    return 'Objectif : $goal points';
  }

  @override
  String get trackingOn => 'Compte automatiquement';

  @override
  String get trackingOff => 'Le compteur ne tourne pas';

  @override
  String get trackingHint =>
      'Dès que l\'écran est verrouillé. Écran allumé : moitié des points.';

  @override
  String get howIsPhoneLying => 'Comment est posé le téléphone ?';

  @override
  String stopWithTime(String time) {
    return 'Stop  ·  $time';
  }

  @override
  String get putPhoneDown => 'Poser le téléphone';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get noSessionsTitle => 'Pas encore de session';

  @override
  String get noSessionsAndroid =>
      'Verrouillez votre téléphone et posez-le. Le reste se fait tout seul.';

  @override
  String get noSessionsIos => 'Appuyez sur le bouton et posez le téléphone.';

  @override
  String get flagScreenOn => 'écran allumé';

  @override
  String get flagMoving => 'en mouvement';

  @override
  String get flagReboot => 'redémarrage';

  @override
  String get modeNormal => 'Sonnerie';

  @override
  String get modeVibrate => 'Vibreur';

  @override
  String get modeSilent => 'Silencieux';

  @override
  String get modeDnd => 'Ne pas déranger';

  @override
  String get modeAirplane => 'Mode avion';

  @override
  String get modePoweredOff => 'Éteint';

  @override
  String get modeShortNormal => 'Son';

  @override
  String get modeShortSilent => 'Silencieux';

  @override
  String get modeShortAirplane => 'Avion';

  @override
  String get weekTitle => 'Cette semaine';

  @override
  String get weekSubtitle => 'Le classement de la semaine entre amis';

  @override
  String get weekError => 'Impossible de charger le classement.';

  @override
  String get weekAddFriendsHint =>
      'Ajoutez des amis dans « Amis » pour participer.';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String hoursMinutesWithoutPhone(int hours, int minutes) {
    return '$hours h $minutes min sans téléphone';
  }

  @override
  String get meOffline => 'vous (hors ligne)';

  @override
  String get friendsTitle => 'Amis';

  @override
  String get friendsSubtitle =>
      'Invitez des amis et voyez qui laisse le plus son téléphone tranquille.';

  @override
  String get friendsOfflineSubtitle => 'Mode hors ligne';

  @override
  String get friendsOfflineBody =>
      'L\'application a été compilée sans backend. Amis et classement arriveront une fois Supabase connecté.';

  @override
  String get yourUsernameHint =>
      'Votre nom d\'utilisateur. Partagez-le avec vos amis.';

  @override
  String get addFriend => 'Ajouter un ami';

  @override
  String get usernameHint => 'nom d\'utilisateur';

  @override
  String requestSent(String name) {
    return 'Demande envoyée à $name.';
  }

  @override
  String userNotFound(String name) {
    return 'Aucun utilisateur nommé « $name ».';
  }

  @override
  String get requests => 'Demandes';

  @override
  String get accept => 'Accepter';

  @override
  String get moreTitle => 'Plus';

  @override
  String get moreSubtitle => 'Réglages, questions et contact';

  @override
  String get dailyGoal => 'Objectif du jour';

  @override
  String get pointsPerDay => 'points par jour';

  @override
  String goalEquivalent(String silent, String airplane) {
    return 'Équivaut à $silent en silencieux ou $airplane en mode avion.';
  }

  @override
  String hoursShort(String hours) {
    return '$hours h';
  }

  @override
  String get other => 'Autre';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get pointsUnit => 'points';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get faqTitle => 'Questions et réponses';

  @override
  String get contact => 'Contact';

  @override
  String get tapToCopy => 'Appuyer pour copier';

  @override
  String get emailCopied => 'E-mail copié';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get footer => 'Free Time · sans pub, sans vente de données';

  @override
  String get authSubtitle =>
      'L\'appli qui vous récompense de ne pas l\'utiliser.\nDes points pour laisser votre téléphone tranquille.';

  @override
  String get emailHint => 'vous@exemple.fr';

  @override
  String get sendLoginLink => 'Envoyer le code';

  @override
  String get noPasswordHint =>
      'Pas de mot de passe. Vous recevez un code à 6 chiffres par e-mail – lisez-le n\'importe où, saisissez-le ici.';

  @override
  String linkSent(String email) {
    return 'Nous avons envoyé un code à $email.';
  }

  @override
  String get codeHint => 'Code à 6 chiffres';

  @override
  String get verifyCode => 'Se connecter';

  @override
  String get codeError =>
      'Code erroné ou expiré. Réessayez ou demandez-en un nouveau.';

  @override
  String get resendCode => 'Envoyer un nouveau code';

  @override
  String get continueWithoutAccount => 'Continuer sans compte';

  @override
  String get withoutAccountHint =>
      'Les points restent sur ce téléphone. Pas d\'amis ni de classement. Vous pourrez vous connecter plus tard sous Plus.';

  @override
  String get signInLater => 'Se connecter ou créer un compte';

  @override
  String get signInLaterHint =>
      'Nécessaire pour les amis et le classement hebdomadaire. Les sessions de ce téléphone sont conservées.';

  @override
  String get authError =>
      'Impossible d\'envoyer le lien. Vérifiez l\'adresse et réessayez.';

  @override
  String get chooseUsername => 'Choisir un nom d\'utilisateur';

  @override
  String get chooseUsernameHint => 'C\'est ainsi que vos amis vous trouvent.';

  @override
  String get usernameTaken =>
      'Nom d\'utilisateur pris ou invalide (a-z, 0-9, _, 3 à 20 caractères).';

  @override
  String get faq1Q => 'Qu\'est-ce que Free Time ?';

  @override
  String get faq1A =>
      'Free Time est le contraire d\'une application qui veut votre attention. Elle vous donne des points pour le temps où votre téléphone reste intouché. Plus le téléphone est loin, plus il y a de points. Et vous pouvez rivaliser avec vos amis pour savoir qui le laisse le plus tranquille.';

  @override
  String get faq2Q => 'Pourquoi existe-t-elle ?';

  @override
  String get faq2A =>
      'Parce que le téléphone est devenu un invité qui ne rentre jamais chez lui. Il est sur la table au dîner, il vient au lit, il interrompt les conversations, et il prend les petites pauses où l\'esprit vagabonderait autrement. Free Time tente de renverser cela : faire de la présence ce qui est récompensé, et rendre l\'écran un peu moins envahissant au quotidien. Pas avec des interdictions, mais avec un petit score bienveillant.';

  @override
  String get faq3Q => 'Comment compte-t-elle ?';

  @override
  String get faq3A =>
      'Sur Android, un petit compteur tourne en permanence en arrière-plan. Quand l\'écran se verrouille ou s\'éteint, une session démarre. Quand vous déverrouillez, elle se termine. Aucun geste nécessaire.\n\nSur iPhone, Apple n\'autorise pas ce type de mesure en arrière-plan. Vous appuyez sur « Poser le téléphone » quand vous le posez et sur « Stop » quand vous le reprenez. L\'application vérifie ensuite si le téléphone est vraiment resté immobile et s\'il a été utilisé entre-temps.';

  @override
  String get faq4Q => 'Comment les points sont-ils attribués ?';

  @override
  String get faq4A =>
      'Vous gagnez 1 point par minute où le téléphone reste posé, multiplié par un facteur selon à quel point il est « absent » :\n\n•  Sonnerie : 1×\n•  Vibreur : 1,5×\n•  Silencieux : 2×\n•  Ne pas déranger / Concentration : 2,5×\n•  Mode avion : 3× avec le Wi-Fi, 4× avec le Bluetooth, 5× tout coupé\n•  Éteint : 10×\n•  Redémarrage : 50 points en plus\n\nSi le téléphone est posé écran allumé (mais verrouillé), les points sont divisés par deux. Si vous le portez dans une poche, aussi. Les facteurs se multiplient : silencieux dans la poche donne 2 × 0,5 = 1×.\n\nExemple : une heure en silencieux sur la table vaut 120 points. Une heure en mode avion tout coupé vaut 300. Une nuit éteint, environ 4 800.';

  @override
  String get faq5Q => 'Qu\'est-ce que l\'objectif du jour ?';

  @override
  String get faq5A =>
      'L\'objectif du jour vous appartient. Par défaut, c\'est 600 points, soit cinq heures en silencieux ou deux heures en mode avion. Vous pouvez le changer dans « Plus ». L\'objectif n\'influence que l\'anneau de la page d\'accueil, pas le classement entre amis.';

  @override
  String get faq6Q => 'Peut-on tricher ?';

  @override
  String get faq6A =>
      'Oui, si on le veut. On peut laisser le téléphone à la maison et aller travailler. Mais alors on a vraiment été sans téléphone, et c\'est tout l\'intérêt. L\'application utilise les capteurs du téléphone pour voir s\'il est resté immobile et si l\'écran a été utilisé, et donne moins de points quand elle ne peut pas le confirmer. Mais c\'est une application entre amis, pas un tribunal.';

  @override
  String get faq7Q => 'Pourquoi l\'iPhone est-il différent d\'Android ?';

  @override
  String get faq7A =>
      'Apple ne laisse pas les applications lire le bouton silencieux, le mode avion ou l\'état de verrouillage, et les applications ne peuvent pas tourner en arrière-plan pendant des heures. Sur iPhone, vous démarrez et arrêtez donc les sessions vous-même et indiquez si le téléphone était en silencieux ou en mode avion. Android donne accès à tout cela, donc la mesure y est automatique.';

  @override
  String get faq8Q => 'Quelles données l\'application conserve-t-elle ?';

  @override
  String get faq8A =>
      'Seulement le nécessaire : quand une session a commencé et fini, dans quel état était le téléphone (sonnerie, silencieux, avion, éteint), s\'il est resté immobile et si l\'écran était allumé. L\'application ne voit pas quelles applications vous utilisez, avec qui vous échangez ni où vous êtes. Vos amis voient vos points de la semaine et votre temps total sans téléphone, pas les sessions individuelles.';

  @override
  String get flagUnverified => 'non vérifié';

  @override
  String get measureTitle => 'Comment nous mesurons';

  @override
  String get measureIntro =>
      'Sur iPhone, vous démarrez et arrêtez vous-même une session. Apple ne laisse pas les apps lire l\'interrupteur silencieux, le mode avion ni l\'écran verrouillé, donc cette partie, c\'est vous qui nous la dites. Deux autorisations facultatives rendent le reste plus précis.';

  @override
  String get measureSessionTitle => 'Vous démarrez et arrêtez';

  @override
  String get measureSessionBody =>
      'Touchez « Poser le téléphone » quand vous le posez et « Stop » quand vous le reprenez. C\'est toute la base de vos points.';

  @override
  String get measureFocusTitle => 'Concentration';

  @override
  String get measureFocusBody =>
      'Ne pas déranger donne 2,5× points. iOS ne dit à l\'app qu\'un seul oui/non : un mode Concentration est-il actif. Pas lequel, pas qui vous écrit.';

  @override
  String get measureScreenTimeTitle => 'Temps d\'écran';

  @override
  String get measureScreenTimeBody =>
      'Rend vos sessions vérifiées. iOS prévient l\'app si le téléphone est utilisé plus d\'une minute pendant une session. L\'app ne voit jamais quelles apps ni combien de temps. Le message d\'Apple parle de restreindre des apps – Free Time ne s\'en sert pas.';

  @override
  String get measurePrivacy =>
      'Tout est lu sur le téléphone et y reste. La seule chose envoyée au serveur : le début, la fin, le mode, le nombre de fois où le téléphone a été pris, et si la session était vérifiée.';

  @override
  String get measureAllow => 'Autoriser';

  @override
  String get measureAllowed => 'Autorisé';

  @override
  String get measureOptional => 'facultatif';

  @override
  String get measureContinue => 'Continuer';

  @override
  String get measureSkip => 'Continuer sans';

  @override
  String get measurePermissions => 'Autorisations';

  @override
  String get modeShortVibrate => 'Vibreur';

  @override
  String get factorTitle => 'Votre facteur en ce moment';

  @override
  String factorPerMinute(String factor) {
    return '$factor× points par minute';
  }

  @override
  String get factorUnverified => 'non vérifié ×0,5';

  @override
  String get factorFocusOn => 'Concentration activée';

  @override
  String get factorIosHint =>
      'Choisissez comment le téléphone est posé — iOS ne peut pas le lire.';

  @override
  String get radioWifiOff => 'Wi-Fi désactivé';

  @override
  String get radioBluetoothOff => 'Bluetooth désactivé';

  @override
  String get radioWifiOn => 'Wi-Fi activé';

  @override
  String get radioBluetoothOn => 'Bluetooth activé';

  @override
  String get airplaneRadiosHint =>
      'En mode avion : désactivez aussi le Wi-Fi et le Bluetooth pour le facteur complet.';

  @override
  String get diagnostics => 'Diagnostic';

  @override
  String get faq9Q =>
      'Pourquoi l\'application demande-t-elle des autorisations ?';

  @override
  String get faq9A =>
      'Sur Android : « Exécuter en arrière-plan » pour que le compteur ne soit pas tué par l\'optimisation de la batterie, et « Notifications » car Android exige une notification visible pour les services en arrière-plan. Sur iPhone, les deux autorisations sont facultatives : « Concentration » pour le bonus Ne pas déranger, et « Temps d\'écran » pour vérifier que le téléphone n\'a pas été utilisé pendant une session. Tout est lu sur le téléphone et jamais partagé. Vous pouvez changer d\'avis sous Plus → Autorisations.';

  @override
  String get faq10Q => 'Consomme-t-elle beaucoup de batterie ?';

  @override
  String get faq10A =>
      'Non. Le compteur n\'écoute que les événements système (écran, profil sonore, mode avion) et utilise le capteur de mouvement basse consommation du téléphone. Il ne mesure pas en continu.';

  @override
  String get faq11Q => 'Quelle est la suite ?';

  @override
  String get faq11A =>
      'Des groupes et des défis (« pas d\'écran avant 9 h »), des séries, un widget pour l\'écran d\'accueil et une version web du classement. Les suggestions sont les bienvenues.';

  @override
  String get faq12Q => 'Qui est derrière, et comment vous contacter ?';

  @override
  String faq12A(String email) {
    return 'Free Time est un petit projet indépendant, sans publicité et sans vente de données. Écrivez à $email pour vos questions, bugs ou idées.';
  }
}
