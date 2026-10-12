import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:dio/dio.dart';
import 'package:lux/util/utils.dart';

import '../tr.dart';
import 'notifier.dart';

class AutoUpdater {
  String? latestVersion;
  String? currentVersion;
  String? latestVersionDownloadLink;
  String? latestInstallerName;
  String? latestInstallerSha256;
  Transfer? downloaderTransfer;

  Future<void> checkForUpdate() async {
    try {
      final dio = Dio();
      var latestReleaseRes = await dio
          .get('https://api.github.com/repos/igoogolx/lux/releases/latest');

      var rawData = latestReleaseRes.data;

      if (rawData.containsKey('assets') && rawData['assets'] is List) {
        var latestAsset = (rawData["assets"] as List).firstWhere((a) {
          var hasName = a.containsKey("name") && a["name"] is String;

          if (!hasName) {
            return false;
          }

          var name = a["name"] as String;

          latestInstallerName = name;

          if (Platform.isWindows) {
            return name.endsWith("windows.exe");
          }

          return false;
        }, orElse: () => null);

        if (latestAsset != null &&
            latestAsset.containsKey("browser_download_url") &&
            latestAsset["browser_download_url"] is String) {
          latestVersionDownloadLink = latestAsset["browser_download_url"];
        }

        if (latestAsset != null &&
            latestAsset.containsKey("digest") &&
            latestAsset["digest"] is String) {
          latestInstallerSha256 =
              latestAsset["digest"].replaceAll('sha256:', '');
        }
      }

      if (rawData.containsKey('tag_name') && rawData['tag_name'] is String) {
        latestVersion = rawData['tag_name'].replaceAll('v', '');
        currentVersion = await getAppVersion();
        debugPrint(
            'latest version: $latestVersion, current version: $currentVersion');
        if (compareVersion(latestVersion, currentVersion) == 1) {
          notifier.show(tr().newVersionMessage, notifierPayloadNewRelease);
        }
      }
    } catch (e) {
      debugPrint('error checking for updates: $e');
    }
  }

  Future<void> download() async {
    if (latestVersionDownloadLink is String && latestInstallerName is String) {
      final task = DownloadTask(
        url: latestVersionDownloadLink!,
        filename: latestInstallerName,
      );

      downloaderTransfer = await FileDownloader().transfers.start(task);
    }
  }
}

final autoUpdater = AutoUpdater();
