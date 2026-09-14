import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "9d49f4dbe352faed5c4b9dca6d5de127446fa32012064a12aae1d99811d8730c";
 const darwinArm64Checksum = "7ebad25fa768dcf68b28712563c7c9a39065b92b4aaef0fb5d57ba563a0bc07f";
 const windowsAmd64Checksum = "1e1cfdbd92a6124c338a2e1c2d4c490447fb8c35fe3a1373b0c93137a9547c54";
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
