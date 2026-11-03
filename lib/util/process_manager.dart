import 'dart:convert';
import 'dart:ffi' show nullptr;
import 'dart:io';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:lux/core/checksum.dart';
import 'package:lux/util/utils.dart';
import 'package:win32/win32.dart'
    show
        COINIT_APARTMENTTHREADED,
        COINIT_DISABLE_OLE1DDE,
        CoInitializeEx,
        CoUninitialize,
        SUCCEEDED,
        SW_HIDE,
        ShellExecute;

import '../error.dart';
import 'elevate.dart';

/// Quotes [arg] so that it is parsed back unchanged from a Windows command
/// line.
String quoteWindowsArgument(String arg) {
  if (arg.isNotEmpty && !arg.contains(RegExp(r'[\s"]'))) {
    return arg;
  }
  final buffer = StringBuffer('"');
  var backslashes = 0;
  for (var i = 0; i < arg.length; i++) {
    final char = arg[i];
    if (char == r'\') {
      backslashes++;
      continue;
    }
    // Backslashes are only special in front of a quote.
    buffer.write(r'\' * (char == '"' ? backslashes * 2 + 1 : backslashes));
    buffer.write(char);
    backslashes = 0;
  }
  buffer.write(r'\' * (backslashes * 2));
  buffer.write('"');
  return buffer.toString();
}

/// Starts [file] as administrator with a hidden window. Returns a value greater
/// than 32 on success.
///
/// It waits for the UAC prompt, so it runs on another isolate.
Future<int> _runAsAdmin(String file, String parameters) {
  return Isolate.run(() {
    final hr = CoInitializeEx(
        nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    try {
      return using((arena) => ShellExecute(
            0,
            'runas'.toNativeUtf16(allocator: arena),
            file.toNativeUtf16(allocator: arena),
            parameters.toNativeUtf16(allocator: arena),
            nullptr,
            SW_HIDE,
          ));
    } finally {
      if (SUCCEEDED(hr)) {
        CoUninitialize();
      }
    }
  });
}

class ProcessManager {
  Process? process;

  final String path;
  final List<String> args;
  final bool needElevate;

  ProcessManager(this.path, this.args, this.needElevate);

  Future<void> run() async {
    if (Platform.isWindows) {
      await verifyCoreBinary(path);
      if (needElevate) {
        final code =
            await _runAsAdmin(path, args.map(quoteWindowsArgument).join(' '));
        if (code <= 32) {
          throw CoreRunError("fail to elevate core, code: $code");
        }
      } else {
        process = await Process.start(path, args);
        process?.stdout.transform(utf8.decoder).forEach(debugPrint);
        process?.stderr.transform(utf8.decoder).forEach(debugPrint);
      }
    } else {
      if (!kDebugMode) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        final isBiggerThanMacOs15 = macOsInfo.majorVersion > 15;
        var owner = await getFileOwner(path);
        if (owner != "root" || isBiggerThanMacOs15) {
          if (!isBiggerThanMacOs15) {
            await verifyCoreBinary(path);
          }
          var i10nLabel = await getInitI10nLabel();
          var code = await elevate(path, i10nLabel.macOSElevateServiceInfo);
          if (code != 0) {
            throw CoreRunError("fail to elevate core, code: $code");
          }
        }
      }
      process = await Process.start(path, args);
      process?.stdout.transform(utf8.decoder).forEach(debugPrint);
      process?.stderr.transform(utf8.decoder).forEach(debugPrint);
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
