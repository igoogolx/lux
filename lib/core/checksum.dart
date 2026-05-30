import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "4090b200a8e78351f40f4792d9e8e5a787b6734baf595457347ceca270497956";
 const darwinArm64Checksum = "4a084480cdcb7d9b480faba015aeb3779a56a9850acbde256a4b2daecddb2f92";
 const windowsAmd64Checksum = "a739843a9649ae7c67c51a6c6768fbfaec5a71928f283ac594e90a05332d76f7";
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
