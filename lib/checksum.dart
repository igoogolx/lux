import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "b76b7dde3d013ca6d9508837b98a8579a4d118c3706ddfe016c7aa502447b38e";
const darwinArm64Checksum =
    "434f996c11a3fb46c5955fa4b7ff054da79264cc38fa34c03c2ea0db77581bbd";
const windowsAmd64Checksum =
    "eb26ab30d4a7d437ff26ea6582e46aef5d166d087d305a56047c0050dc671b3a";

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
