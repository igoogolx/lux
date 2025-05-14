import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "e23041fc8eae99509e73bcf096a6b0bd11c1a7d9d4b4dcf4d1053c5e77bab551";
const darwinAmd64Checksum =
    "cf65c118aa8dad222a851767607692b64a1e89acfa31a14eb0a85ce7aa3dfa65";
const windowsAmd64Checksum =
    "f0757579c0d1d70776f0cff84cf1cdbacdd0bdd459ff4189ea360562815f12e5";

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
