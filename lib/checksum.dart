import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "e86276463a39322e8c0b94160b1a6279642a331c8ba96ebc4bf70344458e48e3";
const darwinArm64Checksum =
    "c54fb3981cba54c843518f4647c7f8530122be12189817501cb48c5df15d6071";
const windowsAmd64Checksum =
    "bdd3cb5fa1d6603012ca2b4a66ef107b7869b667e151b0ea13396494a3a072f7";

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
