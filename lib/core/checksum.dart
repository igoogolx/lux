import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "5854efeaa7fb11a7d16fee070588283fed6e96c0d9e103958e5155bce84044d1";
 const darwinArm64Checksum = "cb0332d6af918ba971ca4d1fabb6cfc72562eefc3d196f0f1c7f50c0b0f930b4";
 const windowsAmd64Checksum = "eade3de47f8200b9ee7868807e6821ed840f03fb7c9a72c625dcdecc53b5d859";
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
