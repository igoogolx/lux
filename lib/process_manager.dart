import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';


class ProcessManager {
  Process? process;

  final String path;
  final List<String> args;

  ProcessManager(this.path, this.args);

  Future<void> run() async {
    if(Platform.isWindows){
      await Process.run(
        'powershell.exe',
        [
          '-noprofile',
          "Start-Process '$path' -Verb RunAs -windowstyle hidden",
          "-ArgumentList \"${args.join(' ')}\""
        ],
        runInShell: false,
      );
    }else{
      process = await Process.start(path, args);
      process?.stdout.transform(utf8.decoder).forEach(debugPrint);
    }
  }
  void exit(){
    process?.kill();
  }
  void watchExit(){
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