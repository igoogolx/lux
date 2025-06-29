import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "c790a0eb26ec7b54b08b3fef144ec59bbeae09188b31066540cd0209938c400e";
const darwinAmd64Checksum =
    "f3f38cebb094a7d5e72e13c3b2939d616be84c92f11b10695af87645d1bef263";
const windowsAmd64Checksum =
    "d522d66f9db837bfe8f1d17bf3f526c4a1c962152b293204f46e39a6f4e850d5";

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
