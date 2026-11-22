import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "52cbdd7da11837802b7bf506b03b4ca1556e319d24789feee5f6c180f1cc8d27";
 const darwinArm64Checksum = "eda72ec006e79730d50b29aaaa3024f40039b15ce4bf8ee963776e8c3476747f";
 const windowsAmd64Checksum = "fff0978cf16f0d9e3052e3a1c5da4c6b4d265f9c2a9909ea339a55a861a7587f";
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
