import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "f77670e04692b13ca2757230db9ca9ada90fdc202b70f338c8136c0456d2ff1c";
 const darwinArm64Checksum = "8acbc9e7d7fba10f585d99792f6d8ac77a7422c1398c64823689df64a206d206";
 const windowsAmd64Checksum = "02e297e70d3841ca5bfc001a9bf3bcfe6146d5016a5eaf187e6648b78d27019f";
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
