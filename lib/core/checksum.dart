import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "deb2759cef9f5ad5f9b9d106afa076ad347d73c45b7fa539ea6b3a400a8430b4";
const darwinArm64Checksum =
    "ad29465d343843046a6a235aee37cbea1798fa9392ec3ad6573d892f13b2b8f1";
const windowsAmd64Checksum =
    "4ff7e465d9f50fa37830e5f2d8cb839012b48e7cdd9df64381c0d64ff3085335";
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
