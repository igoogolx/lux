import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lux/util/utils.dart';
import 'package:path/path.dart' as path;

/// Reads the password for a given proxy ID directly from config.json.
/// This is used by the password peek feature since lux_core doesn't
/// expose a per-proxy detail API endpoint.
Future<String?> readProxyPassword(String proxyId) async {
  try {
    final homeDir = await getHomeDir();
    final configPath = path.join(homeDir, 'config.json');
    final configFile = File(configPath);

    if (!await configFile.exists()) return null;

    final content = await configFile.readAsString();
    final config = jsonDecode(content);

    if (config is! Map<String, dynamic>) return null;

    // The config stores proxies under the "proxy" key as a list
    if (config.containsKey('proxy') && config['proxy'] is List) {
      final proxies = config['proxy'] as List;
      for (final proxy in proxies) {
        if (proxy is Map<String, dynamic> && proxy['id'] == proxyId) {
          return proxy['password'] as String?;
        }
      }
    }

    return null;
  } catch (e) {
    debugPrint('Failed to read proxy password: $e');
    return null;
  }
}

/// Restricts config.json file permissions so only the current user can read it.
/// This prevents other users on the same machine from reading proxy passwords.
Future<void> protectConfigFile() async {
  try {
    final homeDir = await getHomeDir();
    final configPath = path.join(homeDir, 'config.json');
    final configFile = File(configPath);

    if (!await configFile.exists()) return;

    if (Platform.isWindows) {
      // Use icacls to restrict access to the current user only
      final username = Platform.environment['USERNAME'] ?? '';
      if (username.isEmpty) return;

      // Remove inherited permissions and grant only current user full control
      await Process.run('icacls', [
        configPath,
        '/inheritance:r',
        '/grant:r',
        '$username:(F)',
        '/grant:r',
        'SYSTEM:(F)',
      ]);
    } else if (Platform.isMacOS || Platform.isLinux) {
      // Set file permissions to owner-only read/write (chmod 600)
      await Process.run('chmod', ['600', configPath]);
    }

    debugPrint('Protected config.json with restricted permissions');
  } catch (e) {
    debugPrint('Failed to protect config file: $e');
  }
}
