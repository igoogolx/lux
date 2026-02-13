import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "6146982cd80750dff36ccba6b3e1aa117a2d2e2c539c758187acf226442a9a49";
 const darwinArm64Checksum = "c4d39d5f3dacc662773385e8dc4cc1a2206e5d5b44f26275d4a713d1639e140f";
 const windowsAmd64Checksum = "f684132becac1d9399a566299ba0719183bfdf053d77bce81692cfd211858682";
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
