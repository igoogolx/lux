import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "10806e47de5132a2594370cfff8609d462a0e51d80fd0d8fd0f192fffb416084";
 const darwinArm64Checksum = "8bc47e12887f7e700d03b9d332f0099e8b1db3c46d3de11cb49bf5620acb33f1";
 const windowsAmd64Checksum = "322e1431717d74224813d193a31a3350154410daeba581e7190fda80f79a72d4";
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
