import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "3dbe8b7211e3e5d2a4ff9a4aebea97af92ddda5b53ebb1816e970ef4e271aec7";
const darwinArm64Checksum =
    "b663e59539bf6f119fe733b0353a47758386e049cbfbc690fe9287a6a9446d60";
const windowsAmd64Checksum =
    "af8a19ec8ab0b7a3afd3c174d9266261ce0a4a1d0711f1db2e2690e35765f7d5";

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
