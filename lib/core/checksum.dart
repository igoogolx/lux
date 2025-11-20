import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
const darwinAmd64Checksum =
    "0ab84b2b056e5f007c2525f342ab164bee0350b84c6b8556a8918b619784dd25";
const darwinArm64Checksum =
    "0fa6b82c55b806ed92b6226445f9c4ad6e89a153cd4b02ed16d959c372c21e48";
const windowsAmd64Checksum =
    "e7a2a8050a303c747b25b37950650a3c4388a19b14bd0bc91c2db138f125f0af";
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
