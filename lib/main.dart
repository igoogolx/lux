import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/elevate.dart';
import 'package:lux/process_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:system_tray/system_tray.dart';
import 'package:lux/const/const.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:version/version.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';

ProcessManager? process;

Future<int> findAvailablePort(int startPort, int endPort) async {
  for (int port = startPort; port <= endPort; port++) {
    try {
      final serverSocket = await ServerSocket.bind("127.0.0.1", port);
      await serverSocket.close();
      return port;
    } catch (e) {
      // Port is not available
    }
  }
  throw Exception('No available port found in range $startPort-$endPort');
}

Future<void> initSystemTray() async {
  String path = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray.png';

  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    iconPath: path,
  );
  systemTray.setToolTip("Lux");

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Lux', enabled: false),
    MenuItemLabel(label: 'Dashboard', onClicked: (menuItem) => openDashboard()),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exitApp()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? openDashboard() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : openDashboard();
    }
  });
}

void exitApp() {
  process?.exit();
  exit(0);
}

var urlStr = '';

void openDashboard() async {
  final Uri url = Uri.parse(urlStr);
  launchUrl(url);
}

Future<String?> getFileOwner(String path) async {
  var result = await Process.run("ls", ["-l", path]);

  // should be something like:
  // ```
  //     PID TTY          TIME CMD
  //  xxxxx ?        xx:xx:xx process_name
  // ```
  // or emtpy if process does not exist
  var output = result.stdout.toString().trim();

  if (output.isEmpty) {
    return null;
  } else {
    output = output.split("\n").last;

    var parts =
        output.split(" ").where((element) => element.isNotEmpty).toList();

    return parts[2];
  }
}

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add in main method.
  await localNotifier.setup(
    appName: 'Lux',
    // The parameter shortcutPolicy only works on Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
  if (!await FlutterSingleInstance.platform.isFirstInstance()) {
    LocalNotification notification =
        LocalNotification(title: "Lux", body: "App is already running");
    await notification.show();
    exit(0);
  }

  await windowManager.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final port = await findAvailablePort(8000, 9000);
  final Directory appDocumentsDir = await getApplicationSupportDirectory();

  final Version currentVersion = Version.parse(packageInfo.version);
  final homeDir = path.join(
      appDocumentsDir.path, '${currentVersion.major}.${currentVersion.minor}');
  var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
  if (Platform.isMacOS) {
    var owner =
        await getFileOwner(path.join(Paths.assetsBin.path, LuxCoreName.name));
    if (owner != "root") {
      var code = await elevate(corePath);
      if (code != 0) {
        LocalNotification notification =
            LocalNotification(title: "Lux", body: "App is not run as root");
        await notification.show();
        exit(0);
      }
    }
  }
  process = ProcessManager(corePath, ['-home_dir=$homeDir', '-port=$port']);
  await process?.run();
  process?.watchExit();
  final baseUrl = 'http://localhost:$port';
  urlStr = '$baseUrl/?client_version=$currentVersion';
  final manager = CoreManager(baseUrl, process);
  await manager.ping();
  openDashboard();
  initSystemTray();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
