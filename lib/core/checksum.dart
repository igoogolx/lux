import 'dart:io';

import 'package:crypto/crypto.dart';

const darwinAmd64Checksum =
    "7658c2ce0a77169291d259ada54a6b1fa4b9dc7d4fae27a89e199f2491df779c";
const darwinArm64Checksum =
    "a6b4405a5516612ec39a9afee5d4e1de0952a104834406ddda0faa96da290169";
const windowsAmd64Checksum =
    "397a62a959f6b118708e9bdb671db80ae70537cd5b4a233e2ad5ce42f208a960";

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
