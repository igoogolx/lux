import 'dart:io';
import 'package:crypto/crypto.dart';

const darwinArm64Checksum =
    "7cac387e57213e6378f10dff557df5fffea8a095a59856cc5b4ce8c49943a990";
const darwinAmd64Checksum =
    "eb59716097a480cdd85c4ed90fe34ad34de6724a4f53c8eb03f77b2249f73a52";
const windowsAmd64Checksum =
    "920ccc12b626c952fc80423ac6fa2ba7c05078bc52a2995a52d3f1183247d52a";

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
