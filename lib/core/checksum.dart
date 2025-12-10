import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "faba6d70b86bee2cfc9b5be94006b81186d5eb374382803c6079fd5716a8bc1c";
 const darwinArm64Checksum = "0cf4008c0d2f5dbb988d04af13bd717076c86578f53b52a84839c05605975b5a";
 const windowsAmd64Checksum = "88626eba61b4d58ee7767edaddee55092ab47fcd8e259bb69470f01170159d06";
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
