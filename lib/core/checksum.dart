import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "33ee0ae02d90320ad7d44bff70710e7f4e9479d0a12509a560b7eb091ecd971a";
 const darwinArm64Checksum = "37fdc8bb20b8dced3b92d5f676902a2618f6fd311a53b1569692e1f31d9c95fd";
 const windowsAmd64Checksum = "5fd8e281eb3a148a2911b686d8744ec9440c38a95904a184845562045145ab0e";
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
