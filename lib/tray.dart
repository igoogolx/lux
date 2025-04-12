import 'dart:io';
import 'package:lux/tr.dart';
import 'package:tray_manager/tray_manager.dart';

Future<void> initSystemTray() async {
  await trayManager.setIcon(
    Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/tray.icns',
  );
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'lux',
        label: 'Lux',
        disabled: true
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'open_dashboard',
        label: tr().trayDashboardLabel,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Exit',
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
  await trayManager.setToolTip('Lux');
}
