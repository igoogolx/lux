import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "e29f6b97f14453b3406cf44fabb991685deaae38a1cb5b155499fa89efad5db5";
const darwinAmd64Checksum =
    "fb533a61e02f01c23a5758dbdeddbe2f7741910fe3fd02ca6d83f11a1647aea1";
const windowsAmd64Checksum =
    "11f56680f2414a9c51a51f7b94812826598e9ffead547999943c098e7b318691";

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
