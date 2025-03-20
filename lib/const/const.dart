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
  static Directory get assets {
    File mainFile = File(Platform.resolvedExecutable);
    String assetsPath = '../data/flutter_assets/assets';
    if (Platform.isMacOS) {
      assetsPath =
          '../../Frameworks/App.framework/Resources/flutter_assets/assets';
    }
    return Directory(path.normalize(path.join(mainFile.path, assetsPath)));
  }

  static Directory get assetsBin {
    return Directory(path.join(assets.path, 'bin'));
  }
}

const darkBackgroundColor = 0xff292929;
