import 'package:lux/utils.dart';
import 'package:path/path.dart' as path;

Future<Map> readConfig() async {
  var homeDir  = await getHomeDir();
  var configPath = path.join(homeDir, 'config.json');
  return await readJsonFile(configPath);
}


Future<Map> readSetting() async {
  final config = await readConfig();
  if (config.containsKey('setting')) {
    return config['setting'];
  }
  return {};
}

