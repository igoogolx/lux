import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "3436c1004a56e7ecce2e2876b49f50e93940e80fbebba64bcb7cc41e800680e9";
const darwinAmd64Checksum =
    "d6f5b050d846f2d5d090a10d1c441113d9a9a059ac39e578d6a12a45e3f70266";
const windowsAmd64Checksum =
    "d0dc45d547bb361684ad884b2ac4b5cf53cccc6b2509a05b435b16377d0010ef";

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
