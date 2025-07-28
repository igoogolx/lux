import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "ebdf91f6929d5f7ba706e997729692f69f2a5779b82d9485bfaee7bdae5a3dff";
const darwinArm64Checksum =
    "40202d5873e7929d4bd18daec61b82440cdcd8a0141d4854a2a592651a2a9784";
const windowsAmd64Checksum =
    "04d3b31b8b0f4ec18f86ec421b0b681a96c6a4cc7dc0946e27e09db3d5ce9765";

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
