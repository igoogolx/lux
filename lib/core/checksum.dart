import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "d9cf9e49a44804c01c8691df06e504ce34d8682cc049b885ca753b77e81d4f27";
const darwinArm64Checksum =
    "9b36331d6e1b29b84ed13acedc9a96a33c44bbd7669c7e02360c26027cb2358b";
const windowsAmd64Checksum =
    "1eea67d17026f092c1d2c390660bfbf460fe569661dbc58f91b6343d65954c25";
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
