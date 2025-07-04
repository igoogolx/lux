import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "d1be3d460e81f2c349636e0fe8af79e521fd5311ea43e5064b56596780848bd7";
const darwinAmd64Checksum =
    "86d513bd79cf301802467e7957a1203856b1e31d3e858071c02b53588912ae71";
const windowsAmd64Checksum =
    "9e40cd4166f19b980a0992b606a4cc123e98fb6021ea67cc36e09d6f0fd9ab72";

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
