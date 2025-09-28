import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "bb155a59df7c6d528f9c1b4e1e60d48c9b472339cfc7c2fa1f558fc234813db1";
const darwinArm64Checksum =
    "4509f3dd371046b9d04766b338b4885bd8a32eae000f8b96aba65d3e540797c0";
const windowsAmd64Checksum =
    "698186f522867196f71e4d9a503b0318936b0e95de6d43658c3477fd3bb16ac1";

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
