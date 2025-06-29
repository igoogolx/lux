import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "2f4fa515fbad97707d2d6ea549bffe95c761c9169c852507092dec1b28d865f9";
const darwinAmd64Checksum =
    "7bcd72dc0e96790f3ca38f010eac73325da369db49657b8d354c1ffc3d2665cc";
const windowsAmd64Checksum =
    "e734cade227633e23917768e30a6ca5419db32c05a94add0225a69edded300b5";

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
