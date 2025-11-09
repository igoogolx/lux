import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "828a6aec3a10554414f53ef2648b47650a03ea92476bf58220efd166eea4a85b";
const darwinArm64Checksum =
    "a26f668221b52dffbd144bfb847dda9527d505345af86b4a6be3c349b40be017";
const windowsAmd64Checksum =
    "1c4a0aae395c2b83c97c4209bdc6c4c897bc22964a51e98fd779503d36d110f9";
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
