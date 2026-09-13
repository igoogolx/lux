import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "88cf1738d019b0f45bf9593d342fba9b4f0461bf814c7c0d78ba8ce07c659c48";
 const darwinArm64Checksum = "9129ccf027a1cd6a1242f3ce0d278d6ea8828926b571faf0603c24b839122991";
 const windowsAmd64Checksum = "db9edd14caea206da867ccb9c68c04780d8cff2314100cd278b07b27801afda8";
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
