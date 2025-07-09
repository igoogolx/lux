import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "56d8a5bac78719d170cea3d525e23bad7882a292e75c7e696ccd2e34be058602";
const darwinAmd64Checksum =
    "75a4e629a7ea1ff6b20144dcf0e83e8b4033a193184858e3a144c00f9d16c736";
const windowsAmd64Checksum =
    "ae7ef91215b23c341629918d5579d4f44917973787ef0b9f8c7bfe61d9d8cf9a";

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
