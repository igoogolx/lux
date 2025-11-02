import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'constant.dart';

class ReleaseAsset {
  final String digest;
  final String name;

  ReleaseAsset(this.digest, this.name);

  ReleaseAsset.fromJson(Map<String, dynamic> json)
      : digest = (json['digest'] as String).replaceFirst("sha256:", ""),
        name = (json['name'] as String);

  Map<String, dynamic> toJson() => {
        'digest': digest,
        'name': name,
      };
}

class Release {
  final List<ReleaseAsset> assets;

  Release(this.assets);

  Release.fromJson(Map<String, dynamic> json)
      : assets = json['assets'] != null
            ? (json['assets'] as List)
                .map((asset) =>
                    ReleaseAsset.fromJson(asset as Map<String, dynamic>))
                .toList()
            : <ReleaseAsset>[];

  Map<String, dynamic> toJson() =>
      {'assets': assets.map((asset) => asset.toJson()).toList()};
}

Future<void> replaceChecksumSectionInFile(
    String filePath, String newContent) async {
  String content = await File(filePath).readAsString();

  final regex = RegExp(
    r'(// checksum-start)([\s\S]*?)(// checksum-end)',
    multiLine: true,
  );

  String replaced = content.replaceAllMapped(regex, (match) {
    return '${match[1]}\n$newContent\n${match[3]}';
  });

  await File(filePath).writeAsString(replaced);
}

Future<String> getSha256() async {
  final dio = Dio();
  var checksumCode = "";
  try {
    var response = await dio.get(
      "https://api.github.com/repos/igoogolx/itun2socks/releases/tags/v$rawCoreVersion",
    );
    var release = Release.fromJson(response.data);
    for (var asset in release.assets) {
      switch (asset.name) {
        case "itun2socks_${rawCoreVersion}_darwin_arm64":
          checksumCode =
              "$checksumCode const darwinArm64Checksum = \"${asset.digest}\";\n";
        case "itun2socks_${rawCoreVersion}_darwin_amd64":
          checksumCode =
              "$checksumCode const darwinAmd64Checksum = \"${asset.digest}\";\n";
        case "itun2socks_${rawCoreVersion}_windows_amd64.exe":
          checksumCode =
              "$checksumCode const windowsAmd64Checksum = \"${asset.digest}\";";
      }
    }
    return checksumCode;
  } catch (e) {
    return "";
  }
}

Future<void> main() async {
  final newCode = await getSha256();
  await replaceChecksumSectionInFile(
      p.join("lib", "core", "checksum.dart"), newCode);
  print(newCode);
  exit(1);
}
