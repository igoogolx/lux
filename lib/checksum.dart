import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "29e73b5f4825c00d52ebeef3bc1002b5ab2b75a1cb3fc93fd26363d08ae08ab0";
const darwinAmd64Checksum =
    "26158380cb58ed1ef4802ee9824fa8d7ae2f350a49f6176e736bc26afe90c85f";
const windowsAmd64Checksum =
    "274b84919e973329a7cd340b6616e3ee4c0cb1493cf5b08a8b0a3a91da7c97e8";

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
