import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "9d41b0cc91cf378a0deb96e9a75295f47316a23007176cd3ff4a4033bf6a0225";
 const darwinArm64Checksum = "7a7b4f927c18c5c1f0ae141369d69d6d68d26d31be80ebf5247b4f3fddfc3f84";
 const windowsAmd64Checksum = "def51b3258fa0b0851a8614f7787e95eb35650604c0908491cff260e964204a9";
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
