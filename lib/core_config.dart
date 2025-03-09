import 'package:lux/utils.dart';
import 'package:path/path.dart' as path;

Future<Map<String,dynamic>> readConfig() async {
  var homeDir  = await getHomeDir();
  var configPath = path.join(homeDir, 'config.json');
  return await readJsonFile(configPath);
}


Future<Map<String,dynamic>> readSetting() async {
  final config = await readConfig();
  if (config.containsKey('setting') && config['setting'] is Map<String,dynamic>) {
    return config['setting'] as Map<String,dynamic>;
  }
  return {};
}

Future<String> readTheme() async {
  var setting = await readSetting();
  if (setting.containsKey('theme') && setting['theme'] is String) {
    return setting['theme'] as String;
  }
  return "";
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



