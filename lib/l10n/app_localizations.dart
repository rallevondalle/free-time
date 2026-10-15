import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('nl'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Free Time'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The app that rewards you for not using it.'**
  String get tagline;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get navWeek;

  /// No description provided for @navFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get navFriends;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @pointsToday.
  ///
  /// In en, this message translates to:
  /// **'points today'**
  String get pointsToday;

  /// No description provided for @timeWithoutPhone.
  ///
  /// In en, this message translates to:
  /// **'{time} without phone'**
  String timeWithoutPhone(String time);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached'**
  String get goalReached;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal} points'**
  String goalLabel(int goal);

  /// No description provided for @trackingOn.
  ///
  /// In en, this message translates to:
  /// **'Counting automatically'**
  String get trackingOn;

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'The counter is not running'**
  String get trackingOff;

  /// No description provided for @trackingHint.
  ///
  /// In en, this message translates to:
  /// **'Whenever the screen is locked. Screen on gives half points.'**
  String get trackingHint;

  /// No description provided for @howIsPhoneLying.
  ///
  /// In en, this message translates to:
  /// **'How is the phone lying?'**
  String get howIsPhoneLying;

  /// No description provided for @stopWithTime.
  ///
  /// In en, this message translates to:
  /// **'Stop  ·  {time}'**
  String stopWithTime(String time);

  /// No description provided for @putPhoneDown.
  ///
  /// In en, this message translates to:
  /// **'Put the phone down'**
  String get putPhoneDown;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @sessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String sessionCount(int count);

  /// No description provided for @noSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsTitle;

  /// No description provided for @noSessionsAndroid.
  ///
  /// In en, this message translates to:
  /// **'Lock your phone and put it down. The rest happens by itself.'**
  String get noSessionsAndroid;

  /// No description provided for @noSessionsIos.
  ///
  /// In en, this message translates to:
  /// **'Tap the button and put the phone down.'**
  String get noSessionsIos;

  /// No description provided for @flagScreenOn.
  ///
  /// In en, this message translates to:
  /// **'screen on'**
  String get flagScreenOn;

  /// No description provided for @flagMoving.
  ///
  /// In en, this message translates to:
  /// **'moving'**
  String get flagMoving;

  /// No description provided for @flagReboot.
  ///
  /// In en, this message translates to:
  /// **'restart'**
  String get flagReboot;

  /// No description provided for @modeNormal.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get modeNormal;

  /// No description provided for @modeVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get modeVibrate;

  /// No description provided for @modeSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get modeSilent;

  /// No description provided for @modeDnd.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get modeDnd;

  /// No description provided for @modeAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane mode'**
  String get modeAirplane;

  /// No description provided for @modePoweredOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get modePoweredOff;

  /// No description provided for @modeShortNormal.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get modeShortNormal;

  /// No description provided for @modeShortSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get modeShortSilent;

  /// No description provided for @modeShortAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane'**
  String get modeShortAirplane;

  /// No description provided for @weekTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekTitle;

  /// No description provided for @weekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The week\'s standings among your friends'**
  String get weekSubtitle;

  /// No description provided for @weekError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the standings.'**
  String get weekError;

  /// No description provided for @weekAddFriendsHint.
  ///
  /// In en, this message translates to:
  /// **'Add friends under \"Friends\" to compete.'**
  String get weekAddFriendsHint;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsShort(int points);

  /// No description provided for @hoursMinutesWithoutPhone.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m without phone'**
  String hoursMinutesWithoutPhone(int hours, int minutes);

  /// No description provided for @meOffline.
  ///
  /// In en, this message translates to:
  /// **'you (offline)'**
  String get meOffline;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and see who leaves the phone alone the most.'**
  String get friendsSubtitle;

  /// No description provided for @friendsOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get friendsOfflineSubtitle;

  /// No description provided for @friendsOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'The app was built without a backend. Friends and standings arrive when Supabase is connected.'**
  String get friendsOfflineBody;

  /// No description provided for @yourUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your username. Share it with friends.'**
  String get yourUsernameHint;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get usernameHint;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {name}.'**
  String requestSent(String name);

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user named \"{name}\".'**
  String userNotFound(String name);

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Settings, questions and contact'**
  String get moreSubtitle;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @pointsPerDay.
  ///
  /// In en, this message translates to:
  /// **'points per day'**
  String get pointsPerDay;

  /// No description provided for @goalEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Equals {silent} on silent or {airplane} in airplane mode.'**
  String goalEquivalent(String silent, String airplane);

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursShort(String hours);

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pointsUnit.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsUnit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions and answers'**
  String get faqTitle;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @footer.
  ///
  /// In en, this message translates to:
  /// **'Free Time · no ads, no data sales'**
  String get footer;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app that rewards you for not using it.\nPoints for leaving your phone alone.'**
  String get authSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @sendLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendLoginLink;

  /// No description provided for @noPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'No password. You get a 6-digit code by email – read it anywhere, type it here.'**
  String get noPasswordHint;

  /// No description provided for @linkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}.'**
  String linkSent(String email);

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeHint;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get verifyCode;

  /// No description provided for @codeError.
  ///
  /// In en, this message translates to:
  /// **'Wrong or expired code. Try again or request a new one.'**
  String get codeError;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCode;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueWithoutAccount;

  /// No description provided for @withoutAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Points stay on this phone. No friends or leaderboard. You can sign in later under More.'**
  String get withoutAccountHint;

  /// No description provided for @signInLater.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get signInLater;

  /// No description provided for @signInLaterHint.
  ///
  /// In en, this message translates to:
  /// **'Needed for friends and the weekly leaderboard. Sessions on this phone come along.'**
  String get signInLaterHint;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the link. Check the address and try again.'**
  String get authError;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get chooseUsername;

  /// No description provided for @chooseUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'This is how your friends find you.'**
  String get chooseUsernameHint;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username taken or invalid (a-z, 0-9, _, 3-20 characters).'**
  String get usernameTaken;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'What is Free Time?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Free Time is the opposite of an app that wants your attention. It gives you points for the time your phone lies untouched. The further away the phone is, the more points. And you can compete with friends over who leaves it alone the most.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'Why does it exist?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Because the phone has become a guest that never goes home. It sits on the table at dinner, it comes to bed, it interrupts conversations, and it takes the small pauses where your mind would otherwise wander. Free Time is an attempt to turn that around: to make presence the thing that gets rewarded, and to make the screen a little less invasive in everyday life. Not with bans, but with a small, friendly score.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'How does it count?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'On Android a small counter runs in the background all the time. When the screen locks or turns off, a session starts. When you unlock, it ends. No tapping required.\n\nOn iPhone, Apple does not allow that kind of background measurement. There you tap \"Put the phone down\" when you put it down and \"Stop\" when you pick it up. The app then checks whether the phone actually lay still and whether it was used in the meantime.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'How are points awarded?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'You get 1 point per minute the phone lies there. That is multiplied by how \"gone\" it is:\n\n•  Sound on: 1×\n•  Vibrate: 1.5×\n•  Silent: 2×\n•  Do Not Disturb / Focus: 2.5×\n•  Airplane mode: 4×\n•  Turned off: 6×\n•  Restart: 50 points on top\n\nIf the phone lies with the screen on (but locked), points are halved. If you carry it around in a pocket, they are halved too. Multipliers stack, so silent in a pocket is 2 × 0.5 = 1×.\n\nExample: an hour on silent on the table is 120 points. An hour in airplane mode is 240. A night turned off is about 2,900.'**
  String get faq4A;

  /// No description provided for @faq5Q.
  ///
  /// In en, this message translates to:
  /// **'What is the daily goal?'**
  String get faq5Q;

  /// No description provided for @faq5A.
  ///
  /// In en, this message translates to:
  /// **'The daily goal is yours. The default is 600 points, which equals five hours on silent or two and a half hours in airplane mode. You can change it under \"More\". The goal only affects the ring on the front page, not the standings among friends.'**
  String get faq5A;

  /// No description provided for @faq6Q.
  ///
  /// In en, this message translates to:
  /// **'Can you cheat?'**
  String get faq6Q;

  /// No description provided for @faq6A.
  ///
  /// In en, this message translates to:
  /// **'Yes, if you want to. You can leave the phone at home and go to work. But then you actually were without your phone, and that is the whole point. The app uses the phone\'s sensors to see whether it lay still and whether the screen was used, and gives fewer points when it cannot confirm it. But this is an app between friends, not a court.'**
  String get faq6A;

  /// No description provided for @faq7Q.
  ///
  /// In en, this message translates to:
  /// **'Why is iPhone different from Android?'**
  String get faq7Q;

  /// No description provided for @faq7A.
  ///
  /// In en, this message translates to:
  /// **'Apple does not let apps read the silent switch, airplane mode, or whether the phone is locked, and apps may not run in the background for hours. So on iPhone you start and stop sessions yourself and tell the app whether it was on silent or in airplane mode. Android gives access to all of it, so there it is measured automatically.'**
  String get faq7A;

  /// No description provided for @faq8Q.
  ///
  /// In en, this message translates to:
  /// **'What data does the app store?'**
  String get faq8Q;

  /// No description provided for @faq8A.
  ///
  /// In en, this message translates to:
  /// **'Only what is needed: when a session started and ended, which state the phone was in (sound, silent, airplane, off), whether it lay still, and whether the screen was on. The app does not see which apps you use, who you message, or where you are. Your friends can see your weekly points and total time without phone, not the individual sessions.'**
  String get faq8A;

  /// No description provided for @flagUnverified.
  ///
  /// In en, this message translates to:
  /// **'unverified'**
  String get flagUnverified;

  /// No description provided for @measureTitle.
  ///
  /// In en, this message translates to:
  /// **'How we measure'**
  String get measureTitle;

  /// No description provided for @measureIntro.
  ///
  /// In en, this message translates to:
  /// **'On iPhone you start and stop a session yourself. Apple does not let apps read the silent switch, airplane mode or the lock screen, so that part is yours to tell us. Two optional permissions make the rest more precise.'**
  String get measureIntro;

  /// No description provided for @measureSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'You start and stop'**
  String get measureSessionTitle;

  /// No description provided for @measureSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Put the phone down\" when you put it down and \"Stop\" when you pick it up. That is the whole basis for your points.'**
  String get measureSessionBody;

  /// No description provided for @measureFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get measureFocusTitle;

  /// No description provided for @measureFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb gives 2.5× points. iOS only tells the app a single yes/no: is a Focus on. Not which one, not who is messaging you.'**
  String get measureFocusBody;

  /// No description provided for @measureScreenTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get measureScreenTimeTitle;

  /// No description provided for @measureScreenTimeBody.
  ///
  /// In en, this message translates to:
  /// **'Makes your sessions verified. iOS notifies the app if the phone is used for more than a minute during a session. The app never sees which apps or for how long. Apple\'s own prompt mentions restricting apps – Free Time does not use that.'**
  String get measureScreenTimeBody;

  /// No description provided for @measurePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Everything is read on the phone and stays there. The only thing sent to the server is a session\'s start, end, mode, number of pickups, and whether it was verified.'**
  String get measurePrivacy;

  /// No description provided for @measureAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get measureAllow;

  /// No description provided for @measureAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get measureAllowed;

  /// No description provided for @measureOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get measureOptional;

  /// No description provided for @measureContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get measureContinue;

  /// No description provided for @measureSkip.
  ///
  /// In en, this message translates to:
  /// **'Continue without'**
  String get measureSkip;

  /// No description provided for @measurePermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get measurePermissions;

  /// No description provided for @modeShortVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get modeShortVibrate;

  /// No description provided for @factorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your factor right now'**
  String get factorTitle;

  /// No description provided for @factorPerMinute.
  ///
  /// In en, this message translates to:
  /// **'{factor}× points per minute'**
  String factorPerMinute(String factor);

  /// No description provided for @factorUnverified.
  ///
  /// In en, this message translates to:
  /// **'unverified ×0.5'**
  String get factorUnverified;

  /// No description provided for @factorFocusOn.
  ///
  /// In en, this message translates to:
  /// **'Focus is on'**
  String get factorFocusOn;

  /// No description provided for @factorIosHint.
  ///
  /// In en, this message translates to:
  /// **'Pick how the phone is lying — iOS cannot read it.'**
  String get factorIosHint;

  /// No description provided for @radioWifiOff.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi off'**
  String get radioWifiOff;

  /// No description provided for @radioBluetoothOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth off'**
  String get radioBluetoothOff;

  /// No description provided for @radioWifiOn.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi on'**
  String get radioWifiOn;

  /// No description provided for @radioBluetoothOn.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth on'**
  String get radioBluetoothOn;

  /// No description provided for @airplaneRadiosHint.
  ///
  /// In en, this message translates to:
  /// **'In airplane mode: switch off Wi-Fi and Bluetooth too for the full factor.'**
  String get airplaneRadiosHint;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @faq9Q.
  ///
  /// In en, this message translates to:
  /// **'Why does the app ask for permissions?'**
  String get faq9Q;

  /// No description provided for @faq9A.
  ///
  /// In en, this message translates to:
  /// **'On Android: \"Run in background\" so the counter is not killed by battery optimisation, and \"Notifications\" because Android requires a visible notification for background services. On iPhone both permissions are optional: \"Focus\" to give a bonus for Do Not Disturb, and \"Screen Time\" to verify that the phone was not used during a session. Everything is read on the phone and never shared. You can change your mind under More → Permissions.'**
  String get faq9A;

  /// No description provided for @faq10Q.
  ///
  /// In en, this message translates to:
  /// **'Does it use a lot of battery?'**
  String get faq10Q;

  /// No description provided for @faq10A.
  ///
  /// In en, this message translates to:
  /// **'No. The counter only listens for system events (screen, sound profile, airplane mode) and uses the phone\'s low-power motion sensor. It does not measure continuously.'**
  String get faq10A;

  /// No description provided for @faq11Q.
  ///
  /// In en, this message translates to:
  /// **'What is the plan going forward?'**
  String get faq11Q;

  /// No description provided for @faq11A.
  ///
  /// In en, this message translates to:
  /// **'Groups and challenges (\"no screen before 9\"), streaks, a home screen widget, and a web version of the standings. Suggestions are welcome.'**
  String get faq11A;

  /// No description provided for @faq12Q.
  ///
  /// In en, this message translates to:
  /// **'Who is behind it, and how do I get in touch?'**
  String get faq12Q;

  /// No description provided for @faq12A.
  ///
  /// In en, this message translates to:
  /// **'Free Time is a small, independent project with no ads and no selling of data. Write to {email} with questions, bugs or ideas.'**
  String faq12A(String email);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'de', 'en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
