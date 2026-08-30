import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "51c78411ef1dd3a5428af5e790d0fc27fdda746377a8157fc3aaca3f109b82a1";
 const darwinArm64Checksum = "b8bb69a129e9caa70382c75b74f8ca8b778d4473ee25b539f4cf5a18d60b5292";
 const windowsAmd64Checksum = "e04c5be65f4bf73cc3d9b0553aab0beaed0419a28a97f57bd575fd79fe8ed436";
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
