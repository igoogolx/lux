import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "192335ac086db6a76fb184a9c36ccb3445048d371ed0fddf654eb0ae582285c9";
const darwinArm64Checksum =
    "0e085d969262ad5ebb255150a55a9e12970ca02d40bda40982319987bdbbd615";
const windowsAmd64Checksum =
    "8d785507c33f82fc81a66818a1d81862e90574090747819436ed23d7959ccd07";

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
