import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "9a85cdfe9c9b4ef43dd849d593fe1bb6bc82d4d13ea3e1c945a748bddeb34b52";
const darwinArm64Checksum =
    "ca4fedaab90b801f602f4707621a6c0330caa7d1079566e7631aa03cae839a18";
const windowsAmd64Checksum =
    "1a6536c9419fcfeec80e1f2bd6965ec56a4dec0ac8c8a57affa4277c44bfa14c";
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
