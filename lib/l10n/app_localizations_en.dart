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

  @override
  String get tunModeLabel => 'Tun';

  @override
  String get systemModeLabel => 'System';

  @override
  String get mixedModeLabel => 'Mixed';

  @override
  String get proxyModeTooltip =>
      'System proxy usually only supports TCP and is not accepted by all applications, but Tun can handle all traffic. Mixed enables Tun and System at the same time';

  @override
  String get newVersionMessage => 'New available version! Click to Go.';

  @override
  String get uploadLabel => 'upload';

  @override
  String get downloadLabel => 'download';

  @override
  String get proxyLabel => 'Proxy';

  @override
  String get bypassLabel => 'Direct';

  @override
  String get launchAtStartUpMessage => 'Running in background';

  @override
  String get notElevated => 'Not running with elevated permissions.';

  @override
  String get localServer => 'Local Server';

  @override
  String get coreRunError => 'Encounter an error when starting lux_core';

  @override
  String get somethingWrong => 'Something wrong';

  @override
  String get howToFix => 'How to fix';

  @override
  String get elevateCoreStep =>
      'Lux_core is not elevated successfully. Please try to do it manually: \n 1. Copy the following command and run in terminal \n 2. Restart Lux';

  @override
  String get bottomBarTip => 'Hover speed and mode text to see more info';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get qrCode => 'QR Code';

  @override
  String get addProxyTip => 'Add new proxy';
}
