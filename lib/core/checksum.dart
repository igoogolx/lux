import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "4241aa7dfe855013e081e61c4428b324ccc1e86e6d201bbf71cdff0178bf73a0";
const darwinArm64Checksum =
    "231e1571d1c129703b983e4f691285adbf7316ff1fbe83bd703050fcbbc55ebb";
const windowsAmd64Checksum =
    "62303fcb68506eb3d2da2fa6333a4005934259f287829bfb7fa97b9a41c74b78";

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
