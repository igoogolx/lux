import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "e10276e83bef336a6dbab724368d1bc60a04e2447e8dfc880c6e05f0ee5bd552";
const darwinArm64Checksum =
    "aa3548979a72572e114a9c9246e8e76a1da461c497d068162b40039f7c816fff";
const windowsAmd64Checksum =
    "6c33f26b29e2cc672c3887d20b86a4ffa2bc64b68a98bf89d37e2215b837d8fd";

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
