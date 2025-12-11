import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "d0775c4d644bc8eb5996e329dfe66acbc559361cd826c42f93ec5f50aa83abda";
 const darwinArm64Checksum = "0d3cc92a778b5f12e523b1c50ffbf8bd4f94f34046d33e87edddd865080a751c";
 const windowsAmd64Checksum = "3f5de14c413dcabbdd08f5a8579812aa35f525b7695ef30541e0d120eda5ea48";
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
