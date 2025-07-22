import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "061f537ae593688ffab80896a02940efaf0222888d2f2f1b61e96d2acbcf271b";
const darwinAmd64Checksum =
    "a90af3313dc2d32e584b04910f8c08cd22209783e76ee79f97e1a13899e52191";
const windowsAmd64Checksum =
    "b901c8680208d3756aeeebfc42d220f41836a2447ed5d71dcdc70552b6f2b7fb";

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
