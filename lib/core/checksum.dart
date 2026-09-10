import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "2466788f8243c60bf8efaa44c92e6ceeefce7801e5711f271905985187c69fbd";
 const darwinArm64Checksum = "1ccead0a5dc18750102dea36aa4146697bb73eac0cd7494ef69c7456c56b9f64";
 const windowsAmd64Checksum = "2385e50d56def8d248eba84380609293bf3849d70014bafa033b83467837506f";
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
