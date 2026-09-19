import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "322bb145fec39513bcff3ba7574e78bf69076440d88b23c152828b24bba7e214";
 const darwinArm64Checksum = "1b21a0f904ef834b0f81b76e72beab6bd41b90b74a390de5f5a94995434631db";
 const windowsAmd64Checksum = "983f72773995044c9aaa3e3173ba10567457622719f5ff735ffc97de7cdc8378";
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
