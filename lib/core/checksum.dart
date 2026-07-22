import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "710b4635a559ae3a6176f44be9e0e0536433d53ba5bfbaa33f007af3ccaef375";
 const darwinArm64Checksum = "0119982a1bc3c931e976a1678c0da8025dfe64413cd641e8c432e8a5d3b06459";
 const windowsAmd64Checksum = "3d3e2b34d9c0ff758a7fe39c1e8b27d36d743165be9202c69a49808b7e6ada22";
// checksum-end

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
