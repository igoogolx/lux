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
  String get proxyAllRuleLabel => '代理全部';

  @override
  String get proxyGFWRuleLabel => '代理 GFW';

  @override
  String get bypassCNRuleLabel => '绕过 CN';

  @override
  String get bypassAllRuleLabel => '绕过全部';

  @override
  String get goWebDashboardTip => '打开 Web 管理面板';

  @override
  String get tunModeLabel => 'Tun';

  @override
  String get systemModeLabel => '系统代理';

  @override
  String get mixedModeLabel => '混合';

  @override
  String get proxyModeTooltip =>
      'System proxy 通常只支持 TCP 而且不是全部应用都支持, 但是 Tun 能够代理全部流量。混合模式同时开启 Tun 和 System';

  @override
  String get newVersionMessage => '有新版本可用! 点击前往.';

  @override
  String get uploadLabel => '上传';

  @override
  String get downloadLabel => '下载';

  @override
  String get proxyLabel => '代理';

  @override
  String get bypassLabel => '直连';

  @override
  String get launchAtStartUpMessage => '正在后台运行';

  @override
  String get notElevated => '没有以管理员权限运行';

  @override
  String get localServer => '本地服务器';

  @override
  String get coreRunError => '启动 lux_core 时遇到错误';

  @override
  String get somethingWrong => '出错了';

  @override
  String get howToFix => '修复方法';

  @override
  String get elevateCoreStep =>
      '提升 lux_core 的权限失败。 请尝试手动提升: \n 1. 复制以下命令并在终端执行 \n 2. 重启 Lux';
}
