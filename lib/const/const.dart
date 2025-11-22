import 'dart:io';

import 'package:path/path.dart' as path;

class LuxCoreName {
  static String get platform {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'darwin';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static String get arch {
    return const String.fromEnvironment('OS_ARCH', defaultValue: 'amd64');
  }

  static String get ext {
    if (Platform.isWindows) return '.exe';
    return '';
  }

  static String get name {
    return 'lux_core$ext';
  }
}

class Paths {
  static Directory get flutterAssets {
    File mainFile = File(Platform.resolvedExecutable);
    String assetsPath = '../data/flutter_assets';
    if (Platform.isMacOS) {
      assetsPath = '../../Frameworks/App.framework/Resources/flutter_assets';
    }
    return Directory(path.normalize(path.join(mainFile.path, assetsPath)));
  }

  static Directory get assets {
    return Directory(path.join(flutterAssets.path, 'assets'));
  }

  static Directory get assetsBin {
    return Directory(path.join(assets.path, 'bin'));
  }

  static String get appIcon {
    return path.join(
        assets.path, Platform.isWindows ? 'app_icon.ico' : 'tray.icns');
  }

  static String get pubspec {
    return path.join(flutterAssets.path, "pubspec.yaml");
  }
}

const darkBackgroundColor = 0xff292929;

const launchFromStartupArg = 'launch_from_startup';

const localServersGroupKey = 'local_servers';

const latestReleaseUrl = 'https://github.com/igoogolx/lux/releases/latest';

enum ProxyItemAction {
  edit,
  delete,
  qrCode,
}
