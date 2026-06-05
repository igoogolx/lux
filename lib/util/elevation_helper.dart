import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper to verify the user has admin/elevated privileges before
/// revealing sensitive data like proxy passwords.
class ElevationHelper {
  /// Prompts for admin credentials and returns true if verification succeeds.
  ///
  /// On Windows: Verifies the current user's Windows password via a dialog.
  /// On macOS: Uses osascript to prompt for admin password.
  static Future<bool> requestElevation({
    String? message,
    required BuildContext context,
  }) async {
    try {
      if (Platform.isWindows) {
        return await _requestWindowsPasswordVerification(context);
      } else if (Platform.isMacOS) {
        return await _requestMacOSElevation(
            message ?? 'Lux needs admin access to reveal the password');
      }
      return false;
    } catch (e) {
      debugPrint('Elevation request failed: $e');
      return false;
    }
  }

  /// Windows: Shows an in-app password dialog and verifies against Windows credentials.
  static Future<bool> _requestWindowsPasswordVerification(
      BuildContext context) async {
    final username = Platform.environment['USERNAME'] ?? 'user';
    final controller = TextEditingController();
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.lock_outline, size: 20),
          SizedBox(width: 8),
          Text('Verify Identity'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter password for $username to reveal the proxy password.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Windows password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed != true || controller.text.isEmpty) {
      controller.dispose();
      return false;
    }

    final password = controller.text;
    controller.dispose();

    // Verify the password using Windows LogonUser via PowerShell
    final result = await Process.run('powershell.exe', [
      '-noprofile',
      '-NonInteractive',
      '-command',
      r'''
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAuth {
    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool LogonUser(string user, string domain, string pass,
        int logonType, int logonProvider, out IntPtr token);
    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
}
"@
$token = [IntPtr]::Zero
$ok = [WinAuth]::LogonUser("''' +
          username +
          r'''", $env:USERDOMAIN, "''' +
          password +
          r'''", 2, 0, [ref]$token)
if ($token -ne [IntPtr]::Zero) { [WinAuth]::CloseHandle($token) | Out-Null }
Write-Output $ok
''',
    ]);

    final output = result.stdout.toString().trim().toLowerCase();
    return output == 'true';
  }

  /// macOS: Uses osascript to prompt for admin password.
  static Future<bool> _requestMacOSElevation(String message) async {
    final script =
        'do shell script "echo elevated" with prompt "$message" with administrator privileges';
    final result = await Process.run('/usr/bin/osascript', ['-e', script]);
    return result.exitCode == 0;
  }
}
