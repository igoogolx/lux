import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "b7ebe8dbbe5915ca4724231499c25680a903c5511232e2f8bdb9730cf119cb5e";
 const darwinArm64Checksum = "dbd49b8dbd5990a358584c418453001fe2ad218ba77a05f737fddc9ba6c3596c";
 const windowsAmd64Checksum = "808955048c536202b1f8d56918e81c7818adc543642ddebabe20d44f3da5045a";
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
