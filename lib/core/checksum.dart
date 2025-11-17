import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "6c4490f0a68a2af1890733bbc2e67154cc4f777432c9ca6f1b522a0e70038927";
const darwinArm64Checksum =
    "682b6847ba40a0528c24964b20cb2b17db7c69cd673a3e5d9b7e1f688ab0a9dd";
const windowsAmd64Checksum =
    "d9211e0d875fd262948fd0e392c5f6c3129f7784f5492a00d184e765ca830247";
// checksum-end

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
