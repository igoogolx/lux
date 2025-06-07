import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "71c9bf51679227472a11710b873d5f9d37337510884982d625cef063d70c4fba";
const darwinAmd64Checksum =
    "2d9c7994b6d15d90c915c28c12cc8b0800e4fc74c3a69addae5398a5cd3c6e91";
const windowsAmd64Checksum =
    "a1434aaaaf488d0afed09c9d9b2207b7626a1e95e5cca6cb766716df1d7e2772";

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
