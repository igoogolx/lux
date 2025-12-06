import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "67924b208f8d3728249d1769e526fd9736d076b74bc9cca294f7127742dc3784";
 const darwinArm64Checksum = "db6d6e7f8c0d5d81538ad0b564c10f41ccf450e7f3501c22ec9ad86eafc8f052";
 const windowsAmd64Checksum = "22d4aebe141b5266e4b33de3a7ac794c3180c1a094bc69e4d4efca39414b7097";
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
