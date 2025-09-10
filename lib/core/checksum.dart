import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "f3578ea5091279cdf95a524f8c0673a3b0bf43ac018c60bae95e726c189cf931";
const darwinArm64Checksum =
    "abfb5c4dfc391817a1e0485ff0474f748132d40f404639bf75bdcf19a1023dc7";
const windowsAmd64Checksum =
    "edb6334c50e76eb1e668ede9d81f488b0040c95fbad89963073fc5e3eec34c45";

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
