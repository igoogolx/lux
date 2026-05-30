import 'dart:io';

import 'package:crypto/crypto.dart';

// checksum-start
 const darwinAmd64Checksum = "ec3c822343c03fefc6cc47fcb0ffe5680813471fe358753f669cb237983d9eed";
 const darwinArm64Checksum = "000c968308c5565adc6c40e21f93c9150dd0d22b3eec825f4b95ffdb4b4e975c";
 const windowsAmd64Checksum = "6579d8759d0b945264e04cdd469a414b1223b7c14e336cead07fd22e5ad21f71";
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
