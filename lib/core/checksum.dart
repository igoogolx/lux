import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "945d00deca54e5a98a1e415ac53a18c749eb3a91d9a62f6d4431766bf454c8ae";
 const darwinArm64Checksum = "75680a2ec97e762a61467886e4641ffbd319d7f8ec43f79e3b54786489d8a14b";
 const windowsAmd64Checksum = "782be1e45f8579bb982baa8de027a636f2b3044ae5b12812bd824a1345f1c16c";
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
