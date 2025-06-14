// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lux/checksum.dart';
import 'package:path/path.dart' as path;
import 'package:lux/const/const.dart';
import 'package:args/args.dart';

// https://github.com/dart-lang/sdk/issues/31610
final assetsPath =
    path.normalize(path.join(Platform.script.toFilePath(), '../../assets'));
final binDir = Directory(path.join(assetsPath, 'bin'));

const rawCoreName = 'itun2socks';
const rawCoreVersion = '1.28.9-beat.0';

Future<void> downloadFileWith(String url, String savePath) async {
  final dio = Dio();
  try {
    await dio.download(
      url,
      savePath,
    );
    print('✅ File downloaded to: $savePath');
  } catch (e) {
    print('❌ Download failed: $e');
  }
}

void downloadInnoSetupChineseItransFile() async {
  final url =
      'https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/Unofficial/ChineseSimplified.isl';
  final folderPath = path.normalize(path.join(
      Platform.script.toFilePath(), '..', "..", "windows", "packaging", "exe"));
  final fileName = 'ChineseSimplified.isl';
  final savePath = '$folderPath/$fileName';
  await downloadFileWith(url, savePath);
}

Future downloadLatestCore(String arch, String token) async {
  final dio = Dio();
  dio.options.headers = {HttpHeaders.authorizationHeader: 'Bear $token'};
  var releaseArch = LuxCoreName.arch;
  if (arch.isNotEmpty) {
    releaseArch = arch;
  }
  final String luxCoreName =
      '${rawCoreName}_${rawCoreVersion}_${LuxCoreName.platform}_$releaseArch';
  print(luxCoreName);

  final info = await dio.get(
      'https://api.github.com/repos/igoogolx/itun2socks/releases/tags/v$rawCoreVersion');
  final Map<String, dynamic> latest = (info.data['assets'] as List<dynamic>)
      .firstWhere((it) => (it['name'] as String).contains(luxCoreName));

  final String name = latest['name'];
  final tempFile = File(path.join(binDir.path,  LuxCoreName.name));

  print('Downloading $name');
  await dio.download(latest['browser_download_url'], tempFile.path);
  print('Download $name Success');
  await verifyCoreBinary(tempFile.path);
  if(Platform.isMacOS){
    await Process.run('chmod', ['+x', tempFile.path]);
  }
}

const targetArch = 'target-arch';
const secret = 'secret';

void main(List<String> arguments) async {
  try {
    final parser = ArgParser()
      ..addOption(targetArch, defaultsTo: '', abbr: 'a')
      ..addOption(secret, defaultsTo: '', abbr: 's');

    ArgResults argResults = parser.parse(arguments);

    if ((await binDir.exists())) {
      await binDir.delete(recursive: true);
    }
    await binDir.create();

    if (Platform.isWindows) {
      downloadInnoSetupChineseItransFile();
    }

    await downloadLatestCore(
        argResults[targetArch] as String, argResults[secret]);
  } catch (e) {
    print(e);
    exit(1);
  }
}
