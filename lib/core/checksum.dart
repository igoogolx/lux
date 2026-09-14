import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "4baaebf3c5ae3ed9c4b6fa756e76521c703d1519b76394441840b48dce22bcb8";
 const darwinArm64Checksum = "de861b4f9ebd195c91787e69fcc2d3484956e508fa182123d100adc1a3c31022";
 const windowsAmd64Checksum = "0823baabd26224ab6db0c4f555e712d95c659223f7de68db688846b227398910";
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
