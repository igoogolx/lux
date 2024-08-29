import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:system_tray/system_tray.dart';

Future<void> initSystemTray(
  exitApp,
  focusWindow,
) async {
  String path = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray.icns';

  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(iconPath: path, isTemplate: true);
  systemTray.setToolTip("Lux");

  // create context menu
  final Menu menu = Menu();
  final List<MenuItemBase> menuItems = [
    MenuItemLabel(label: 'Lux', enabled: false),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exitApp()),
  ];

  await menu.buildFrom(menuItems);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      if (Platform.isWindows) {
        focusWindow();
      } else {
        systemTray.popUpContextMenu();
      }
    } else if (eventName == kSystemTrayEventRightClick) {
      if (!Platform.isWindows) {
        focusWindow();
      } else {
        systemTray.popUpContextMenu();
      }
    }
  });
}
