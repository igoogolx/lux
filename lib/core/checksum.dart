import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "2e8febaa96971af41bc0b4cfc83a9ae50b78a44a92f2be21e35bbe5943321333";
const darwinArm64Checksum =
    "87b4813024439875509270f17c8ccabf168ec939bc1295f28c2104d453ae5240";
const windowsAmd64Checksum =
    "4e9accc96b06217c13223136d07b99acbd902948d91769dbfcbaa32a53238717";

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
