import 'package:dio/dio.dart';

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

Future<void> getSha256() async {
  final dio = Dio();
  try {
    var response = await dio.get(
      "https://api.github.com/repos/igoogolx/itun2socks/releases/tags/v$rawCoreVersion",
    );
    var release = Release.fromJson(response.data);
    for (var asset in release.assets) {
      if (<String>[
        "itun2socks_${rawCoreVersion}_darwin_arm64",
        "itun2socks_${rawCoreVersion}_darwin_amd64",
        "itun2socks_${rawCoreVersion}_windows_amd64.exe"
      ].contains(asset.name)) {
        print('${asset.name}: ${asset.digest}');
      }
    }
  } catch (e) {
    print('fail to get sha256: $e');
  }
}

Future<void> main() async {
  await getSha256();
}
