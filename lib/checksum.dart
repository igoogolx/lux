import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "7bfc2039212ce3bdd0398b36e2be390923981058a67cd3347f3e01d4208919eb";
const darwinAmd64Checksum =
    "f666638a4c62986dcf8a9a5074d319a9ffe60461589c2528405ad4ddd2224130";
const windowsAmd64Checksum =
    "e6b07eae89349e537d2d8b1c1a19002a24e3cef1d43f5904f3197add9ced56e0";

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
