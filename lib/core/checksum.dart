import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "9b4c769c14fc83131ca0f50b772a4f06c50b346b6a142776b7f89ed4873f2489";
 const darwinArm64Checksum = "d7d85e5d8a90283ecc9ad1747b117bf0f401642072f3688f1a8b99a60ef99bc6";
 const windowsAmd64Checksum = "4a7b23778bb82d2e9ed2c6da44d2600733b712f0d2378bc0c3096f652949a3fc";
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
