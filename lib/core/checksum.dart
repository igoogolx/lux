import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "dad0173eea32e5b85076228b58a63691301cb29a18e5c819adc8c61be078b37c";
const darwinArm64Checksum =
    "c97b374460408c5d44de91d85a2b50d1da8a9ce3fb0b71a9e48a595076641cc5";
const windowsAmd64Checksum =
    "007df5615946e92d2723c7f0adfb309454271be94a9b913698ecef0a83ff0af5";
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
