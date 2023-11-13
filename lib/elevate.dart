import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

var sudoCommandPath = "/usr/bin/osascript";

Future<String?> getFileOwner(String path) async {
  var result = await Process.run("ls", ["-l", path]);

  var output = result.stdout.toString().trim();

  if (output.isEmpty) {
    return null;
  } else {
    output = output.split("\n").last;

    var parts =
        output.split(" ").where((element) => element.isNotEmpty).toList();

    return parts[2];
  }
}

Future<int> elevate(String path, message) async {
  var escapedCommand =
      "sudo chown root:wheel $path&&sudo chmod 770 $path&&sudo chmod +sx $path";
  var messageArg = " with prompt \"$message\"";
  var escapedScript =
      "tell current application\n   activate\n   do shell script \"$escapedCommand\"$messageArg with administrator privileges without altering line endings\nend tell";

  var process = await Process.start(sudoCommandPath, ["-e", escapedScript]);

  process.stdout.transform(utf8.decoder).forEach(debugPrint);
  process.stderr.transform(utf8.decoder).forEach(debugPrint);
  return await process.exitCode;
}
