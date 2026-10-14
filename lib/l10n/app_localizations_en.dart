// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Free Time';

  @override
  String get tagline => 'The app that rewards you for not using it.';

  @override
  String get offline => 'offline';

  @override
  String get navToday => 'Today';

  @override
  String get navWeek => 'Week';

  @override
  String get navFriends => 'Friends';

  @override
  String get navMore => 'More';

  @override
  String get greetingNight => 'Good night';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Hello';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get pointsToday => 'points today';

  @override
  String timeWithoutPhone(String time) {
    return '$time without phone';
  }

  @override
  String get goalReached => 'Daily goal reached';

  @override
  String goalLabel(int goal) {
    return 'Goal: $goal points';
  }

  @override
  String get trackingOn => 'Counting automatically';

  @override
  String get trackingOff => 'The counter is not running';

  @override
  String get trackingHint =>
      'Whenever the screen is locked. Screen on gives half points.';

  @override
  String get howIsPhoneLying => 'How is the phone lying?';

  @override
  String stopWithTime(String time) {
    return 'Stop  ·  $time';
  }

  @override
  String get putPhoneDown => 'Put the phone down';

  @override
  String get today => 'Today';

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
  String get noSessionsTitle => 'No sessions yet';

  @override
  String get noSessionsAndroid =>
      'Lock your phone and put it down. The rest happens by itself.';

  @override
  String get noSessionsIos => 'Tap the button and put the phone down.';

  @override
  String get flagScreenOn => 'screen on';

  @override
  String get flagMoving => 'moving';

  @override
  String get flagReboot => 'restart';

  @override
  String get modeNormal => 'Sound';

  @override
  String get modeVibrate => 'Vibrate';

  @override
  String get modeSilent => 'Silent';

  @override
  String get modeDnd => 'Do Not Disturb';

  @override
  String get modeAirplane => 'Airplane mode';

  @override
  String get modePoweredOff => 'Off';

  @override
  String get modeShortNormal => 'Sound';

  @override
  String get modeShortSilent => 'Silent';

  @override
  String get modeShortAirplane => 'Airplane';

  @override
  String get weekTitle => 'This week';

  @override
  String get weekSubtitle => 'The week\'s standings among your friends';

  @override
  String get weekError => 'Could not load the standings.';

  @override
  String get weekAddFriendsHint => 'Add friends under \"Friends\" to compete.';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String hoursMinutesWithoutPhone(int hours, int minutes) {
    return '${hours}h ${minutes}m without phone';
  }

  @override
  String get meOffline => 'you (offline)';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsSubtitle =>
      'Invite friends and see who leaves the phone alone the most.';

  @override
  String get friendsOfflineSubtitle => 'Offline mode';

  @override
  String get friendsOfflineBody =>
      'The app was built without a backend. Friends and standings arrive when Supabase is connected.';

  @override
  String get yourUsernameHint => 'Your username. Share it with friends.';

  @override
  String get addFriend => 'Add friend';

  @override
  String get usernameHint => 'username';

  @override
  String requestSent(String name) {
    return 'Request sent to $name.';
  }

  @override
  String userNotFound(String name) {
    return 'No user named \"$name\".';
  }

  @override
  String get requests => 'Requests';

  @override
  String get accept => 'Accept';

  @override
  String get moreTitle => 'More';

  @override
  String get moreSubtitle => 'Settings, questions and contact';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get pointsPerDay => 'points per day';

  @override
  String goalEquivalent(String silent, String airplane) {
    return 'Equals $silent on silent or $airplane in airplane mode.';
  }

  @override
  String hoursShort(String hours) {
    return '$hours h';
  }

  @override
  String get other => 'Other';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get pointsUnit => 'points';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get faqTitle => 'Questions and answers';

  @override
  String get contact => 'Contact';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String get emailCopied => 'Email copied';

  @override
  String get signOut => 'Sign out';

  @override
  String get footer => 'Free Time · no ads, no data sales';

  @override
  String get authSubtitle =>
      'The app that rewards you for not using it.\nPoints for leaving your phone alone.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get sendLoginLink => 'Send login link';

  @override
  String get noPasswordHint => 'No password. You get a link by email.';

  @override
  String linkSent(String email) {
    return 'We sent a link to $email. Open it on your phone to sign in.';
  }

  @override
  String get authError =>
      'Could not send the link. Check the address and try again.';

  @override
  String get chooseUsername => 'Choose a username';

  @override
  String get chooseUsernameHint => 'This is how your friends find you.';

  @override
  String get usernameTaken =>
      'Username taken or invalid (a-z, 0-9, _, 3-20 characters).';

  @override
  String get faq1Q => 'What is Free Time?';

  @override
  String get faq1A =>
      'Free Time is the opposite of an app that wants your attention. It gives you points for the time your phone lies untouched. The further away the phone is, the more points. And you can compete with friends over who leaves it alone the most.';

  @override
  String get faq2Q => 'Why does it exist?';

  @override
  String get faq2A =>
      'Because the phone has become a guest that never goes home. It sits on the table at dinner, it comes to bed, it interrupts conversations, and it takes the small pauses where your mind would otherwise wander. Free Time is an attempt to turn that around: to make presence the thing that gets rewarded, and to make the screen a little less invasive in everyday life. Not with bans, but with a small, friendly score.';

  @override
  String get faq3Q => 'How does it count?';

  @override
  String get faq3A =>
      'On Android a small counter runs in the background all the time. When the screen locks or turns off, a session starts. When you unlock, it ends. No tapping required.\n\nOn iPhone, Apple does not allow that kind of background measurement. There you tap \"Put the phone down\" when you put it down and \"Stop\" when you pick it up. The app then checks whether the phone actually lay still and whether it was used in the meantime.';

  @override
  String get faq4Q => 'How are points awarded?';

  @override
  String get faq4A =>
      'You get 1 point per minute the phone lies there. That is multiplied by how \"gone\" it is:\n\n•  Sound on: 1×\n•  Vibrate: 1.5×\n•  Silent: 2×\n•  Do Not Disturb / Focus: 2.5×\n•  Airplane mode: 4×\n•  Turned off: 6×\n•  Restart: 50 points on top\n\nIf the phone lies with the screen on (but locked), points are halved. If you carry it around in a pocket, they are halved too. Multipliers stack, so silent in a pocket is 2 × 0.5 = 1×.\n\nExample: an hour on silent on the table is 120 points. An hour in airplane mode is 240. A night turned off is about 2,900.';

  @override
  String get faq5Q => 'What is the daily goal?';

  @override
  String get faq5A =>
      'The daily goal is yours. The default is 600 points, which equals five hours on silent or two and a half hours in airplane mode. You can change it under \"More\". The goal only affects the ring on the front page, not the standings among friends.';

  @override
  String get faq6Q => 'Can you cheat?';

  @override
  String get faq6A =>
      'Yes, if you want to. You can leave the phone at home and go to work. But then you actually were without your phone, and that is the whole point. The app uses the phone\'s sensors to see whether it lay still and whether the screen was used, and gives fewer points when it cannot confirm it. But this is an app between friends, not a court.';

  @override
  String get faq7Q => 'Why is iPhone different from Android?';

  @override
  String get faq7A =>
      'Apple does not let apps read the silent switch, airplane mode, or whether the phone is locked, and apps may not run in the background for hours. So on iPhone you start and stop sessions yourself and tell the app whether it was on silent or in airplane mode. Android gives access to all of it, so there it is measured automatically.';

  @override
  String get faq8Q => 'What data does the app store?';

  @override
  String get faq8A =>
      'Only what is needed: when a session started and ended, which state the phone was in (sound, silent, airplane, off), whether it lay still, and whether the screen was on. The app does not see which apps you use, who you message, or where you are. Your friends can see your weekly points and total time without phone, not the individual sessions.';

  @override
  String get faq9Q => 'Why does the app ask for permissions?';

  @override
  String get faq9A =>
      'On Android: \"Run in background\" so the counter is not killed by battery optimisation, and \"Notifications\" because Android requires a visible notification for background services. On iPhone: \"Motion\" to see whether the phone lay still, \"Focus\" to give a bonus for Do Not Disturb, and \"Screen Time\" to detect whether the phone was used during a session.';

  @override
  String get faq10Q => 'Does it use a lot of battery?';

  @override
  String get faq10A =>
      'No. The counter only listens for system events (screen, sound profile, airplane mode) and uses the phone\'s low-power motion sensor. It does not measure continuously.';

  @override
  String get faq11Q => 'What is the plan going forward?';

  @override
  String get faq11A =>
      'Groups and challenges (\"no screen before 9\"), streaks, a home screen widget, and a web version of the standings. Suggestions are welcome.';

  @override
  String get faq12Q => 'Who is behind it, and how do I get in touch?';

  @override
  String faq12A(String email) {
    return 'Free Time is a small, independent project with no ads and no selling of data. Write to $email with questions, bugs or ideas.';
  }
}
