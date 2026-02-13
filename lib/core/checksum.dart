import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "ced7c8f1ebb021497b89bb0e01956673c6ac36b42b8a38035d7e5756db763bce";
 const darwinArm64Checksum = "86e424828cca07677715abd496f7f9b716c5fdec6970faca29be72971a320b3b";
 const windowsAmd64Checksum = "daf6b370266bd9f8de7679941d4ea5a0d7716987d348a33b7fb660f38aa3e549";
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
