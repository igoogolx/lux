import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "98cf3cf55448317bdc32500193583ed6f8d249fba3d7b0a411e80758be58ebf0";
const darwinArm64Checksum =
    "0e0e27ffbcdc48aae07ae96959770a30ae5e12885cc416acf095e58c53db22ce";
const windowsAmd64Checksum =
    "509286daefb909f8b44606a55da3ea52c7cab64ec60e652a9bba776e0dc6a4b4";

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
