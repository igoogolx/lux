import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "d96b5136efdbddd4fd2638dcb23d5ed4e7d00c16c9f97dc9ec011861a7e3e659";
const darwinArm64Checksum =
    "a57a9406636e6ab25bd3f0f1edd20dc55009434d875c4d55ea1eb9313bc96a66";
const windowsAmd64Checksum =
    "7f607d02f859f81815f9d4920452b4839152fe934d46422f927c093265cc209d";

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
