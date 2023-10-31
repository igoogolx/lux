import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

Future<int> elevate(String path) async {
  var process = await Process.start("osascript",["-e",'do shell script "sudo chown root $path&&sudo chmod 770 $path&&sudo chmod +sx $path" with administrator privileges']);
  process.stdout.transform(utf8.decoder).forEach(debugPrint);
  process.stderr.transform(utf8.decoder).forEach(debugPrint);
  return await process.exitCode;
}
