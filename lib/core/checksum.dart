import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "82b5c6557398401f0931f95117dd5e4d675ffef26498ce8d77f102e7c753b8b1";
const darwinArm64Checksum =
    "b47e6766bb79f91add39d493d7bc3d09be8a5e6cfa1dd90a7322c8ecc805ea5d";
const windowsAmd64Checksum =
    "b8fe447f37a5ae938d6e7c73d0db1324f66c7bc129be8b335aa00c13c6de0f6a";

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
