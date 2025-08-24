import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "f6e932b18d42e5bbac278faa43c5b7af1460668051d7caf8a7d3bf09fbdb4ffa";
const darwinArm64Checksum =
    "fed4b23111d0a22b39ab9bee60c371666bec5f0f8cdd5153885dfa4dab2fd8cb";
const windowsAmd64Checksum =
    "bb9ebe363b8ed469acdb3528a9d6a8d9f0bae032338c5145f46019dd87287e5d";

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
