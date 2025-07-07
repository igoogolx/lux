import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "5535721c2bcd34ba0364b7432af6f3de91e24169f886651d6c8afb3b410926da";
const darwinAmd64Checksum =
    "863ee768e6a8be3041f3dd653f29e03e56731ed5d3794d355fba97f6ad2c9448";
const windowsAmd64Checksum =
    "b4886045a3d7a74d0a49afa3f5edead906ed83ec285bc99ce57faaf8c3bba550";

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
