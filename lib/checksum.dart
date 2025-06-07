import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "e85c3cf858199a87f7ae09e66d501924ee99951672f4feee0c320a84a6652aa4";
const darwinAmd64Checksum =
    "e5239528f71a671d137288e9cec4a8c7977e929ce5a9fa8abb0b556bb9716a52";
const windowsAmd64Checksum =
    "4e97cacc9c2a1ca0cab68efcf921f41801fda452c280fc69a3b737e039752202";

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
