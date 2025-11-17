import 'package:flutbook/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:flutbook/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
