import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "cba5205b80bac092c46c20513d05ec6690430e479c182b42813c50f54d3fa9e5";
const darwinAmd64Checksum =
    "e70b0b50d8a3038a6e54516d33ed16c05b361cbfd094ed255d8a441143312da9";
const windowsAmd64Checksum =
    "bfcaadcfc4c93153d7ef86a5d4f63b2acfad657e049b98f0996f75017fb67eb5";

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
