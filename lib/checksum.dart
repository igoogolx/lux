import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "3e2281e634a774e1c5cddc4f1895b72a3be7dc010bf36a4f0984605864fe25d9";
const darwinAmd64Checksum =
    "5216db27ab68994b98a2783222b44afd51724c0c347c13b5841ea04a7541bd58";
const windowsAmd64Checksum =
    "b5ae5b3e6620cd147e17ccab7c3b9eb2a889c67e3b905ef45ddc2a58dc4e46c1";

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
