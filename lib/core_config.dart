import 'package:lux/utils.dart';
import 'package:path/path.dart' as path;

Future<Map<String, dynamic>> readConfig() async {
  try {
    var homeDir = await getHomeDir();
    var configPath = path.join(homeDir, 'config.json');
    return await readJsonFile(configPath);
  } catch (e) {
    return {};
  }
}

Future<Map<String, dynamic>> readSetting() async {
  try {
    final config = await readConfig();
    if (config.containsKey('setting') &&
        config['setting'] is Map<String, dynamic>) {
      return config['setting'] as Map<String, dynamic>;
    }
    return {};
  } catch (e) {
    return {};
  }
}

enum ThemeType {
  light,
  dark,
}

Future<ThemeType> readTheme() async {
  var setting = await readSetting();
  if (setting.containsKey('theme') && setting['theme'] is String) {
    if (setting['theme'] == 'dark') {
      return ThemeType.dark;
    }
  }
  return ThemeType.light;
}

enum ClientMode {
  light,
  webview,
}

Future<ClientMode> readClientMode() async {
  var setting = await readSetting();
  if (setting.containsKey('clientMode') && setting['clientMode'] is String) {
    if (setting['clientMode'] == 'light') {
      return ClientMode.light;
    }
  }
  return ClientMode.webview;
}

Future<bool> readAutoLaunch() async {
  var setting = await readSetting();
  if (setting.containsKey('autoLaunch') && setting['autoLaunch'] is bool) {
    return setting['autoLaunch'] as bool;
  }
  return false;
}

Future<bool> readAutoConnect() async {
  var setting = await readSetting();
  if (setting.containsKey('autoConnect') && setting['autoConnect'] is bool) {
    return setting['autoConnect'] as bool;
  }
  return false;
}

Future<String> readLanguage() async {
  var setting = await readSetting();
  if (setting.containsKey('language') && setting['language'] is String) {
    return setting['language'] as String;
  }
  return 'system';
}
