import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "a14bdde0ff10c0e4c7bd02d7bf1aab9e4541a5966890d4728c55328c51fea4e3";
const darwinArm64Checksum =
    "c0187e5dd924b959307804f30217779744fe207d057f6417b723c9c23f80fb9a";
const windowsAmd64Checksum =
    "2156a4d205272fa24eb824af9357f7f5c7b43d473433f2cd1e13beafa86c082c";

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
