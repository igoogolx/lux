import 'package:flutter/material.dart';
import 'package:lux/util/utils.dart';
import 'package:path/path.dart' as path;

import '../const/const.dart';

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

ThemeMode convertTheme(String theme) {
  switch (theme) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

Future<ThemeMode> readTheme() async {
  var setting = await readSetting();
  if (setting.containsKey('theme') && setting['theme'] is String) {
    return convertTheme(setting['theme']);
  }
  return ThemeMode.system;
}

enum ClientMode {
  light,
  webview,
}

Future<ClientMode> readClientMode() async {
  var setting = await readSetting();
  if (setting.containsKey('lightClientMode') &&
      setting['lightClientMode'] is bool) {
    if (setting['lightClientMode']) {
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

enum ProxyMode { tun, system, mixed }

Future<ProxyMode> readProxyMode() async {
  var setting = await readSetting();
  if (setting.containsKey('mode') && setting['mode'] is String) {
    var mode = setting['mode'] as String;
    switch (mode) {
      case 'system':
        return ProxyMode.system;
      case 'tun':
        return ProxyMode.tun;
      case 'mixed':
        return ProxyMode.mixed;
    }
  }
  return ProxyMode.tun;
}

class ProxyItem {
  final String id;
  final String name;
  final String? server;
  final int? port;
  final String? subscriptionUrl;

  ProxyItem(this.id, this.name, this.server, this.port, this.subscriptionUrl);

  ProxyItem.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as String),
        name = (json['name'] as String),
        server = (json['server'] as String),
        subscriptionUrl = (json['subscriptionUrl'] is String
            ? json['subscriptionUrl'] as String
            : null),
        port = (json['port'] as int);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ProxyListGroup {
  late String selectedId;
  late List<ProxyItem> allProxies;
  late List<ProxyList> groups;

  ProxyListGroup(this.allProxies, this.selectedId, this.groups);

  ProxyListGroup.fromJson(Map<String, dynamic> json) {
    allProxies = json['proxies'] != null
        ? (json['proxies'] as List)
            .map((asset) => ProxyItem.fromJson(asset as Map<String, dynamic>))
            .toList()
        : <ProxyItem>[];
    groups = convertListToGroup(allProxies);
    selectedId = (json['selectedId'] as String);
  }

  List<ProxyList> convertListToGroup(List<ProxyItem> items) {
    Map<String, List<ProxyItem>> groupMap = {};
    for (var item in items) {
      if (item.subscriptionUrl is String) {
        var groupName = item.subscriptionUrl as String;
        if (!groupMap.containsKey(groupName)) {
          groupMap[groupName] = [];
        }
        groupMap[groupName]!.add(item);
      } else {
        if (!groupMap.containsKey(localServersGroupKey)) {
          groupMap[localServersGroupKey] = [];
        }
        groupMap[localServersGroupKey]!.add(item);
      }
    }

    List<ProxyList> groups = [];
    groupMap.forEach((groupName, proxies) {
      groups.add(ProxyList(proxies, groupName));
    });

    return groups;
  }
}

class ProxyList {
  final List<ProxyItem> proxies;
  final String url;

  ProxyList(this.proxies, this.url);

  Map<String, dynamic> toJson() =>
      {'proxies': proxies.map((asset) => asset.toJson()).toList()};
}

class RuleList {
  final List<String> rules;
  String selectedId;

  RuleList(this.rules, this.selectedId);

  RuleList.fromJson(Map<String, dynamic> json)
      : rules = json['rules'] != null
            ? (json['rules'] as List).map((asset) => asset as String).toList()
            : <String>[],
        selectedId = (json['selectedId'] as String);

  Map<String, dynamic> toJson() => {'rules': rules};
}

// Define the data classes
class Speed {
  final Proxy proxy;
  final Direct direct;

  Speed({required this.proxy, required this.direct});

  factory Speed.fromJson(Map<String, dynamic> json) {
    return Speed(
      proxy: Proxy.fromJson(json['proxy']),
      direct: Direct.fromJson(json['direct']),
    );
  }
}

class Total {
  final Proxy proxy;
  final Direct direct;

  Total({required this.proxy, required this.direct});

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      proxy: Proxy.fromJson(json['proxy']),
      direct: Direct.fromJson(json['direct']),
    );
  }
}

class Proxy {
  final int upload;
  final int download;

  Proxy({required this.upload, required this.download});

  factory Proxy.fromJson(Map<String, dynamic> json) {
    return Proxy(
      upload: json['upload'],
      download: json['download'],
    );
  }
}

class Direct {
  final int upload;
  final int download;

  Direct({required this.upload, required this.download});

  factory Direct.fromJson(Map<String, dynamic> json) {
    return Direct(
      upload: json['upload'],
      download: json['download'],
    );
  }
}

class TrafficData {
  final Speed speed;
  final Total total;

  TrafficData({required this.speed, required this.total});

  factory TrafficData.fromJson(Map<String, dynamic> json) {
    return TrafficData(
      speed: Speed.fromJson(json['speed']),
      total: Total.fromJson(json['total']),
    );
  }
}

class RuntimeStatus {
  final String addr;
  final String name;
  final bool isStarted;

  RuntimeStatus(
      {required this.addr, required this.name, required this.isStarted});

  factory RuntimeStatus.fromJson(Map<String, dynamic> json) {
    return RuntimeStatus(
      addr: json['addr'] is String ? json['addr'] : '',
      name: json['name'] is String ? json['name'] : '',
      isStarted: json['isStarted'] is bool ? json['isStarted'] : false,
    );
  }
}

class Setting {
  late final ProxyMode mode;
  late final bool keepConnectedWhenSlept;

  Setting(this.mode);

  Setting.fromJson(Map<String, dynamic> json) {
    mode = (json.containsKey('mode') && json['mode'] is String)
        ? (json['mode'] == 'tun'
            ? ProxyMode.tun
            : (json['mode'] == 'system' ? ProxyMode.system : ProxyMode.mixed))
        : ProxyMode.mixed;
    keepConnectedWhenSlept = (json.containsKey('keepConnectedWhenSlept') &&
        json['keepConnectedWhenSlept'] is bool);
  }
}
