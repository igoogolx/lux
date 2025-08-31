import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "a7dcc444ffd1df993f038dd141f38a5630349ef104825ad0edbbad5c3e5cce88";
const darwinArm64Checksum =
    "1d288c197dd4f83a3b86dcc7a43a9f4c3d56f5183aa4f456fe55c991e6b5ced5";
const windowsAmd64Checksum =
    "6069bcbc52d1f3919becc69e0a6fb870759c07d9d20cdbe15f8e8a3f9dc4974c";

Future<void> verifyCoreBinary(String filePath) async {
  var input = File(filePath);
  if (!input.existsSync()) {
    throw "File $filePath does not exist.";
  }
  var value = await sha256.bind(input.openRead()).first;
  var curChecksum = value.toString();
  var validChecksums = <String>[];
  if (Platform.isWindows) {
    validChecksums.add(windowsAmd64Checksum);
  } else {
    validChecksums.add(darwinAmd64Checksum);
    validChecksums.add(darwinArm64Checksum);
  }
  if (!validChecksums.contains(curChecksum)) {
    throw "Checksum of core binary is not matched. Expect $validChecksums, get $curChecksum.";
  }
}
