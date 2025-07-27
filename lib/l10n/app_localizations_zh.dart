// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get trayDashboardLabel => '管理面板';

  @override
  String get exit => '退出';

  @override
  String get noConnectionMsg => '无网络连接，已断开';

  @override
  String get reconnectedMsg => '已重连';

  @override
  String connectOnOpenErrMsg(Object msg) {
    return '自动连接失败: $msg';
  }

  @override
  String setAutoLaunchErrMsg(Object msg) {
    return '设置自启动失败: $msg';
  }

  @override
  String get connectOnOpenMsg => '已自动连接';

  @override
  String get proxyAllRuleLabel => 'Proxy All';

  @override
  String get proxyGFWRuleLabel => 'Proxy GFW';

  @override
  String get bypassCNRuleLabel => 'Bypass CN';

  @override
  String get bypassAllRuleLabel => 'Bypass All';

  @override
  String get goWebDashboardTip => 'Go To Web Dashboard';
}
