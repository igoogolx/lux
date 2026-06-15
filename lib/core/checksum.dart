import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "a9b1821a90ed3d07ab0afe0473c1ac6136ef70a671639685f8afd9eed9c4ae94";
 const darwinArm64Checksum = "831573b8031a3c27cc4838bd484305603242c5a68cdd00800c33fe9b4b9a3ad7";
 const windowsAmd64Checksum = "34eb20f1f82baef43a3ed0a536a5d2db907f6d814c1dab0568004a7ea16c9c8a";
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
