import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "726bb7c79c8fe1503974db220022d929beee3addd0b6e6182f11d14426269bf0";
 const darwinArm64Checksum = "94cb9b8a88483a613b595c3c7c437e39ad30b2ae0a10b1e2899f5fce451831b7";
 const windowsAmd64Checksum = "8339cfa3ab84406f884508deb821c359a35a2092e6136d14a4167f440dcfd5c5";
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
