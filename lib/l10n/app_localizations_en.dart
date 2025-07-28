// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get trayDashboardLabel => 'Open Dashboard';

  @override
  String get exit => 'Exit';

  @override
  String get noConnectionMsg => 'No available network. Disconnected';

  @override
  String get reconnectedMsg => 'Reconnected';

  @override
  String connectOnOpenErrMsg(Object msg) {
    return 'Fail to connect on open: $msg';
  }

  @override
  String setAutoLaunchErrMsg(Object msg) {
    return 'Fail to set auto launch: $msg';
  }

  @override
  String get connectOnOpenMsg => 'Connect on open';

  @override
  String get proxyAllRuleLabel => 'Proxy All';

  @override
  String get proxyGFWRuleLabel => 'Proxy GFW';

  @override
  String get bypassCNRuleLabel => 'Bypass CN';

  @override
  String get bypassAllRuleLabel => 'Bypass All';

  @override
  String get goWebDashboardTip => 'Open web dashboard';
}
