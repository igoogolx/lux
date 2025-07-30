import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "21a5759b749a1ee3bd41a875c53105c75db03be4eea85a5d5be1589815cf3e14";
const darwinArm64Checksum =
    "d1ef4b1f7ffc7de8170a9208f916e58bd7c43993c48ed46d31f3caefe707f21d";
const windowsAmd64Checksum =
    "7db0495cc478a851d8881f547201c001f4a7b2284d2223d1ad2e99ec2bcb3037";

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
