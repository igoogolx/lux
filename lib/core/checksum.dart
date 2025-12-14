import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "383aecd188dd765bf1594f1c42368e046af03a2224bcb969e00111bce094cb16";
 const darwinArm64Checksum = "1fb85e6831094b4a9284f2eac64a1fd0d216296e5192dfa3b741f1382f85bffb";
 const windowsAmd64Checksum = "ceebda6b2e6343381e349528753560f12260980f0731becf4e8c5edd2845dbe7";
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
