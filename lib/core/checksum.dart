import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "66c36a0aa0600783467220e6a6cc14dc68066424a8007352532fe32b162ecf05";
 const darwinArm64Checksum = "978c557441fd4dbc8e348a301543cd3a7463113e867de30789183ff656f587f8";
 const windowsAmd64Checksum = "a32208c5422700b1e592b1095aba6f83da8d25044cea6a770bb6fa742087efb7";
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
