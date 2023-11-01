import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';


Future<String?> getFileOwner(String path) async {
  var result = await Process.run("ls", ["-l", path]);

  // should be something like:
  // ```
  //     PID TTY          TIME CMD
  //  xxxxx ?        xx:xx:xx process_name
  // ```
  // or emtpy if process does not exist
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

Future<int> elevate(String path) async {
  var process = await Process.start("osascript",["-e",'do shell script "sudo chown root $path&&sudo chmod 770 $path&&sudo chmod +sx $path" with administrator privileges']);
  process.stdout.transform(utf8.decoder).forEach(debugPrint);
  process.stderr.transform(utf8.decoder).forEach(debugPrint);
  return await process.exitCode;
}
