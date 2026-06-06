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

/// Checks if the NOPASSWD sudoers entry already exists for lux_core.
Future<bool> _isSudoersConfigured(String corePath) async {
  final realPath = '${corePath}_real';
  final sudoersFile = File('/etc/sudoers.d/lux_core');
  if (!await sudoersFile.exists()) return false;
  try {
    final content = await sudoersFile.readAsString();
    return content.contains(realPath);
  } catch (_) {
    return false;
  }
}

/// Checks if the core binary is already wrapped with the sudo script.
Future<bool> _isWrapped(String corePath) async {
  final realPath = '${corePath}_real';
  final realFile = File(realPath);
  return await realFile.exists();
}

Future<int> elevate(String path, message) async {
  // Check if the NOPASSWD elevation is already set up
  if (await _isWrapped(path) && await _isSudoersConfigured(path)) {
    debugPrint('Elevation already configured via sudoers, skipping prompt.');
    return 0;
  }

  // First time: set up the wrapper + sudoers entry (requires one-time admin prompt)
  final dir = File(path).parent.path;
  final realPath = '$dir/lux_core_real';
  final user = Platform.environment['USER'] ?? 'root';

  // Build the setup commands
  final commands = [
    // Remove quarantine
    'xattr -cr "${File(path).parent.parent.parent.parent.parent.parent.path}"',
    // Move binary to _real
    if (!await File(realPath).exists()) 'mv "$path" "$realPath"',
    // Create wrapper script
    if (!await File(realPath).exists() || !(await File(path).exists() && (await File(path).readAsString()).contains('lux_core_real')))
      'printf \'#!/bin/bash\\nexec sudo "$dir/lux_core_real" "\$@"\\n\' > "$path" && chmod 755 "$path"',
    // Set up sudoers
    'echo "$user ALL=(root) NOPASSWD: $realPath *" > /etc/sudoers.d/lux_core',
    'chmod 0440 /etc/sudoers.d/lux_core',
    'visudo -c -f /etc/sudoers.d/lux_core || rm -f /etc/sudoers.d/lux_core',
  ].where((c) => c.isNotEmpty).join(' && ');

  // Fall back to the standard osascript elevation for the one-time setup
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
