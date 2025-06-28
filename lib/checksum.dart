import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "edfce9dafdb66fb49492e638980f20a70409581263ef4d65cb039df2e7ef305b";
const darwinAmd64Checksum =
    "861eb47dd2b614d1ab8b2e56d1ecba8bea8292a2af05a4431ca28a292f982be9";
const windowsAmd64Checksum =
    "251aeb85402318fee56ac42b2bfe22585d27f03337d07bd69e3e6d59cbce8b82";

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
