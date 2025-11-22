import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "ade4d12906916d96c7e5308c593b459127f14c61f770dac2a49a5900506566d5";
const darwinArm64Checksum =
    "efe90db1a61598279631672097ed2e7542eb132459ccc9a03a31234ac316b62c";
const windowsAmd64Checksum =
    "bfb025d23033677911393e3ce26f0d3c26e1c5df56d8071864706426d04baaf0";
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
