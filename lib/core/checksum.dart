import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "fd7ab48a360e13f855f494e8af217f34d07d88ad205f6ee143265023cd432e7b";
 const darwinArm64Checksum = "ad94962b39557a484d33ec879145a78392646f8276efd459186c3d55c1a3bc13";
 const windowsAmd64Checksum = "04deb9ac3b7aa9f6b5b62bfd63d233fb46e11dc584f27b1bab525a979b751b90";
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
