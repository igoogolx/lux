import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:system_tray/system_tray.dart';

Future<void> initSystemTray(void Function() openDashboard, exitApp, focusWindow,
    bool isWebviewSupported) async {
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

  if (!isWebviewSupported) {
    menuItems.insert(
        1,
        MenuItemLabel(
            label: 'Dashboard', onClicked: (menuItem) => openDashboard()));
  }

  await menu.buildFrom(menuItems);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      if (Platform.isWindows) {
        if (isWebviewSupported) {
          focusWindow();
        } else {
          openDashboard();
        }
      } else {
        systemTray.popUpContextMenu();
      }
    } else if (eventName == kSystemTrayEventRightClick) {
      if (!Platform.isWindows) {
        if (isWebviewSupported) {
          focusWindow();
        } else {
          openDashboard();
        }
      } else {
        systemTray.popUpContextMenu();
      }
    }
  });
}
