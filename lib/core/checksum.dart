import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "ce75219ac26cf0b54ae0cc16f6d94a25d539e34c200aede861f749e22cf11096";
 const darwinArm64Checksum = "9acc977db20b7eac605a33fc7a62eefc116e7adbcf50a1fe6c4156885b3597a2";
 const windowsAmd64Checksum = "83a23e9087a37a50bb0785e98a5d32efcf96fab9a5bc26805288e1ab463e1c6c";
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
