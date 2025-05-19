import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "e48a791bc373a0e84a87b8a86085b4baac3d7a7e93ba8080aeb19de4ef473515";
const darwinAmd64Checksum =
    "b6a86555e567973d073e89e4a871c3c016e383658bde1b05feed8a670d95120f";
const windowsAmd64Checksum =
    "e57e46cbdc8c6c7beee242e531337b046788e7fb0fe4bf9c039e1593af7065ef";

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
