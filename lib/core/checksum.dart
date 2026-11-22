import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "7df3623320d42ebb322134ee524d2b15f5d96b2747971f42b32a5f1c59caba37";
 const darwinArm64Checksum = "296537c0e1ec466a454063496839bc3cd67fe6a5d40a5fe5df64fd490abcdea5";
 const windowsAmd64Checksum = "e0be0b18e4019ba7892f5ab15d46fa7dc68e9b6448768bb882cb4a4629ad7101";
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

Future<bool> verifyFileSha256(String filePath, fileSha256) async {
  var input = File(filePath);
  if (!input.existsSync()) {
    throw "File $filePath does not exist.";
  }
  var value = await sha256.bind(input.openRead()).first;
  var curChecksum = value.toString();

  return curChecksum == fileSha256;
}
