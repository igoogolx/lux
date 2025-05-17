import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lux/checksum.dart';
import 'package:lux/notifier.dart';
import 'package:lux/utils.dart';

import 'elevate.dart';

class ProcessManager {
  Process? process;

  final String path;
  final List<String> args;

  ProcessManager(this.path, this.args);

  Future<void> run() async {
    await verifyCoreBinary(path);
    if (Platform.isWindows) {
      process = await Process.start(
        'powershell.exe',
        [
          '-noprofile',
          "Start-Process '$path' -Verb RunAs -windowstyle hidden",
          "-ArgumentList \"${args.join(' ')}\""
        ],
        runInShell: false,
      );
    } else  {
      if(!kDebugMode){
        var owner = await getFileOwner(path);
        if (owner != "root") {
          var i10nLabel = await getInitI10nLabel();
          var code = await elevate(path, i10nLabel.macOSElevateServiceInfo);
          if (code != 0) {
            notifier.show(i10nLabel.macOSElevateServiceInfo);
            exitApp();
          }
        }
      }
      process = await Process.start(path, args);
      process?.stdout.transform(utf8.decoder).forEach(debugPrint);
    }
  }

  void exit() {
    process?.kill();
  }

  void watchExit() {
    // watch process kill
    // ref https://github.com/dart-lang/sdk/issues/12170
    if (Platform.isMacOS) {
      // windows not support https://github.com/dart-lang/sdk/issues/28603
      // for macos 任务管理器退出进程
      ProcessSignal.sigterm.watch().listen((_) {
        stdout.writeln('exit: sigterm');
        exit();
      });
    }
    // for macos, windows ctrl+c
    ProcessSignal.sigint.watch().listen((_) {
      stdout.writeln('exit: sigint');
      exit();
    });
  }
}
