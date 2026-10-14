import 'package:flutter/widgets.dart';

import '../core/session.dart';
import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension SessionModeL10n on SessionMode {
  String label(AppLocalizations t) => switch (this) {
        SessionMode.normal => t.modeNormal,
        SessionMode.vibrate => t.modeVibrate,
        SessionMode.silent => t.modeSilent,
        SessionMode.dnd => t.modeDnd,
        SessionMode.airplane => t.modeAirplane,
        SessionMode.poweredOff => t.modePoweredOff,
      };
}
