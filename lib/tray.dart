import 'dart:io';

import 'package:lux/tr.dart';
import 'package:tray_manager/tray_manager.dart';

Future<void> initSystemTray(
    Function onShowWindow, Function onOpenDashboard, Function onExitApp) async {
  final trayIcon = TrayIcon.create()!;
  trayIcon.icon = ImageAsset.fromAsset(
    Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray.icns',
  );
  trayIcon.setTooltip('Lux');

  trayIcon.addListener((event) {
    if (event is TrayIconClickedEvent) {
      onShowWindow();
    } else if (event is TrayIconRightClickedEvent) {
      trayIcon.openContextMenu();
    }
  });

  final menu = Menu.create()!;
  final showWindowItem = MenuItem.createWithLabelAndType(
    'Lux',
    MenuItemType.normal,
  );
  showWindowItem?.isEnabled = false;
  menu.addItem(showWindowItem);
  menu.addSeparator();

  final openDashboardItem = MenuItem.createWithLabelAndType(
      tr().trayDashboardLabel, MenuItemType.normal);

  openDashboardItem?.addListener((event) {
    if (event is MenuItemClickedEvent) {
      onOpenDashboard();
    }
  });

  menu.addItem(openDashboardItem);

  final exitAppItem =
      MenuItem.createWithLabelAndType(tr().exit, MenuItemType.normal);

  exitAppItem?.addListener((event) {
    if (event is MenuItemClickedEvent) {
      onExitApp();
    }
  });

  menu.addItem(openDashboardItem);

  trayIcon.setContextMenu(menu);
  trayIcon.setVisible(true);
}
