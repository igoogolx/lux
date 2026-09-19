import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "2efa82037d7ac75f1b88aebd613610479ada47fcd113ae879313f4308a88be87";
 const darwinArm64Checksum = "d2f7bbc2a79a2a28aad3c62cbefa9403b34b977cd5d76192fdffef54e10297cc";
 const windowsAmd64Checksum = "5ea212239afd92644c8401adaa4d6f93dc204ea7e18e7171c3a8bae918c04558";
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
