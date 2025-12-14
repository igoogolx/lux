import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @trayDashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get trayDashboardLabel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @noConnectionMsg.
  ///
  /// In en, this message translates to:
  /// **'No available network. Disconnected'**
  String get noConnectionMsg;

  /// No description provided for @reconnectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Reconnected'**
  String get reconnectedMsg;

  /// No description provided for @connectOnOpenErrMsg.
  ///
  /// In en, this message translates to:
  /// **'Fail to connect on open: {msg}'**
  String connectOnOpenErrMsg(Object msg);

  /// No description provided for @setAutoLaunchErrMsg.
  ///
  /// In en, this message translates to:
  /// **'Fail to set auto launch: {msg}'**
  String setAutoLaunchErrMsg(Object msg);

  /// No description provided for @connectOnOpenMsg.
  ///
  /// In en, this message translates to:
  /// **'Connect on open'**
  String get connectOnOpenMsg;

  /// No description provided for @proxyAllRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Proxy All'**
  String get proxyAllRuleLabel;

  /// No description provided for @proxyGFWRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Proxy GFW'**
  String get proxyGFWRuleLabel;

  /// No description provided for @bypassCNRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Bypass CN'**
  String get bypassCNRuleLabel;

  /// No description provided for @bypassAllRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Bypass All'**
  String get bypassAllRuleLabel;

  /// No description provided for @goWebDashboardTip.
  ///
  /// In en, this message translates to:
  /// **'Open web dashboard'**
  String get goWebDashboardTip;

  /// No description provided for @tunModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tun'**
  String get tunModeLabel;

  /// No description provided for @systemModeLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemModeLabel;

  /// No description provided for @mixedModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedModeLabel;

  /// No description provided for @proxyModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'System proxy usually only supports TCP and is not accepted by all applications, but Tun can handle all traffic. Mixed enables Tun and System at the same time'**
  String get proxyModeTooltip;

  /// No description provided for @newVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'New available version! Click to Go.'**
  String get newVersionMessage;

  /// No description provided for @uploadLabel.
  ///
  /// In en, this message translates to:
  /// **'upload'**
  String get uploadLabel;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'download'**
  String get downloadLabel;

  /// No description provided for @proxyLabel.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get proxyLabel;

  /// No description provided for @bypassLabel.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get bypassLabel;

  /// No description provided for @launchAtStartUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Running in background'**
  String get launchAtStartUpMessage;

  /// No description provided for @notElevated.
  ///
  /// In en, this message translates to:
  /// **'Not running with elevated permissions.'**
  String get notElevated;

  /// No description provided for @localServer.
  ///
  /// In en, this message translates to:
  /// **'Local Servers'**
  String get localServer;

  /// No description provided for @coreRunError.
  ///
  /// In en, this message translates to:
  /// **'Encounter an error when starting lux_core'**
  String get coreRunError;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something wrong'**
  String get somethingWrong;

  /// No description provided for @howToFix.
  ///
  /// In en, this message translates to:
  /// **'How to fix'**
  String get howToFix;

  /// No description provided for @elevateCoreStep.
  ///
  /// In en, this message translates to:
  /// **'Lux_core is not elevated successfully. Please try to do it manually: \n 1. Copy the following command and run in terminal \n 2. Restart Lux'**
  String get elevateCoreStep;

  /// No description provided for @bottomBarTip.
  ///
  /// In en, this message translates to:
  /// **'Hover speed and mode text to see more info'**
  String get bottomBarTip;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @addProxyTip.
  ///
  /// In en, this message translates to:
  /// **'Add new proxy'**
  String get addProxyTip;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
