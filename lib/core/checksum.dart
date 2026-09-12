import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "3e5158e5864ae5d07c456b97d6aedd33f25a7723c53fdcacc28c05a6032a171a";
 const darwinArm64Checksum = "9eb54abd4f3a84a7c7e7064eadc392b05391601ed3097b4e5edf0a1a97b9fadb";
 const windowsAmd64Checksum = "43a740e7544c6a292c7284bdedb56f488c7c2eda65a0d03dc90fcb0c24eb82b1";
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
