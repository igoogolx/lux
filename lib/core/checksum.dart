import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "ceb8217b02b5acf3d5c05bce1543ea23139b9b6ca5de69947562298170dc5056";
 const darwinArm64Checksum = "e4ae83a5c5bbaed502152641bd935e46a193505ee69d92f73dc9b38f540de764";
 const windowsAmd64Checksum = "d4af069c6559372e139a0cdac88c11972f0cc4a51640fdf5a1cb2915983074c6";
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
