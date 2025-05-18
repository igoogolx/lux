import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "ffbcaf789a29529a316474051f10b4e9b134b37d02ba95ac0770a7430bb00168";
const darwinAmd64Checksum =
    "770e51b7266a5a9854a9eec3a9e5a3e56f34e0078a3d8cf760ea54c9d3daf08f";
const windowsAmd64Checksum =
    "9898b606dcfcfb064f9f97c0dc143b4f18094684da2fee9128c4f73dc6b5ceab";

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
