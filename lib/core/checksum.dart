import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "24c0412d5972b7cac9bff4c411f26c5d3876f463ad83cba9baa897d8f4254e34";
 const darwinArm64Checksum = "74f7e5f15a5b55bb261cf52eb5eebca6762cc51b8b90a03b9176b3135332d20f";
 const windowsAmd64Checksum = "8a2bb8bfcc6bbb672020a4e5cdd6eb9570af2547fbb5345f5c4fd8d7c8e1148b";
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
