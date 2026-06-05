import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lux/core/core_config.dart';
import 'package:lux/core/core_manager.dart';
import 'package:lux/tr.dart';
import 'package:lux/util/elevation_helper.dart';

/// Set of proxy IDs that were created/edited in the current session.
/// These can be peeked without elevation (first-time view).
final Set<String> _sessionCreatedProxyIds = {};

/// Call this when a proxy is newly created or edited in the current session
/// to allow one-time peek without elevation.
void markProxyAsNewlyCreated(String proxyId) {
  _sessionCreatedProxyIds.add(proxyId);
}

/// Shows a dialog that reveals the proxy password.
/// Requires admin elevation unless the proxy was just created in this session.
Future<void> showPasswordPeekDialog({
  required BuildContext context,
  required CoreManager coreManager,
  required ProxyItem proxyItem,
}) async {
  final isNewlyCreated = _sessionCreatedProxyIds.contains(proxyItem.id);

  // If not newly created, require elevation first
  if (!isNewlyCreated) {
    // Show a brief message that elevation is needed
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr().peekPasswordTitle),
        content: Text(tr().peekPasswordElevationRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;
    if (!context.mounted) return;

    final elevated = await ElevationHelper.requestElevation(
      message: tr().peekPasswordElevationRequired,
      context: context,
    );

    if (!elevated) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr().peekPasswordElevationFailed)),
      );
      return;
    }
  }

  if (!context.mounted) return;

  // Use the core API GET /proxies/{id} which returns the decrypted password
  final detail = await coreManager.getProxyDetail(proxyItem.id);

  if (!context.mounted) return;

  final password = detail?.password;

  if (password == null || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr().peekPasswordNoPassword)),
    );
    return;
  }

  // After first successful peek, remove from "newly created" set
  // so subsequent peeks require elevation
  _sessionCreatedProxyIds.remove(proxyItem.id);

  // Show the password in a dialog
  await showDialog(
    context: context,
    builder: (context) => _PasswordRevealDialog(password: password),
  );
}

class _PasswordRevealDialog extends StatefulWidget {
  final String password;

  const _PasswordRevealDialog({required this.password});

  @override
  State<_PasswordRevealDialog> createState() => _PasswordRevealDialogState();
}

class _PasswordRevealDialogState extends State<_PasswordRevealDialog> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr().peekPasswordTitle),
      content: Row(
        children: [
          Expanded(
            child: SelectableText(
              _obscured ? '••••••••••••' : widget.password,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscured = !_obscured;
              });
            },
            tooltip: _obscured ? 'Show' : 'Hide',
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.password));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr().peekPasswordCopied)),
              );
            },
            tooltip: 'Copy',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}
