import 'package:flutter/material.dart';
import 'package:lux/core/core_manager.dart';
import 'package:lux/core/core_config.dart';

/// Dialog for creating or editing a proxy configuration.
/// Supports HTTP, SOCKS5, and Shadowsocks proxy types.
class ProxyEditDialog extends StatefulWidget {
  final CoreManager coreManager;
  final ProxyDetail? initialValue; // null = create new
  final VoidCallback onSaved;

  const ProxyEditDialog({
    super.key,
    required this.coreManager,
    this.initialValue,
    required this.onSaved,
  });

  @override
  State<ProxyEditDialog> createState() => _ProxyEditDialogState();
}

class _ProxyEditDialogState extends State<ProxyEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _server;
  late int _port;
  late String _username;
  late String _password;
  late String _type;
  late String _passwordMode;
  late int _passwordTTLMinutes;
  late bool _lockOnSave;

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isEditing => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    final iv = widget.initialValue;
    _name = iv?.name ?? '';
    _server = iv?.server ?? '';
    _port = iv?.port ?? 1080;
    _username = iv?.raw['username'] as String? ?? '';
    _password = iv?.password ?? '';
    _type = iv?.type ?? 'http';
    _passwordMode = iv?.raw['passwordMode'] as String? ?? 'persistent';
    _passwordTTLMinutes = (iv?.raw['passwordTTLMinutes'] as num?)?.toInt() ?? 60;
    _lockOnSave = false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final proxyData = <String, dynamic>{
        'name': _name,
        'server': _server,
        'port': _port,
        'username': _username,
        'password': _password,
        'type': _type,
        'passwordMode': _passwordMode,
      };

      if (_passwordMode == 'timed') {
        proxyData['passwordTTLMinutes'] = _passwordTTLMinutes;
      }

      if (isEditing) {
        proxyData['id'] = widget.initialValue!.id;
        await widget.coreManager.updateProxy(widget.initialValue!.id, proxyData);
      } else {
        await widget.coreManager.addProxy(proxyData);
      }

      if (_lockOnSave && isEditing) {
        await widget.coreManager.lockProxyPassword(widget.initialValue!.id);
      }

      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Proxy' : 'Create Proxy',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Proxy type
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const [
                            DropdownMenuItem(value: 'http', child: Text('HTTP')),
                            DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
                            DropdownMenuItem(value: 'ss', child: Text('Shadowsocks')),
                          ],
                          onChanged: isEditing ? null : (v) => setState(() => _type = v!),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          onSaved: (v) => _name = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        // Server
                        TextFormField(
                          initialValue: _server,
                          decoration: const InputDecoration(labelText: 'Server'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          onSaved: (v) => _server = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        // Port
                        TextFormField(
                          initialValue: _port.toString(),
                          decoration: const InputDecoration(labelText: 'Port'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final p = int.tryParse(v ?? '');
                            if (p == null || p < 1 || p > 65535) return 'Invalid port';
                            return null;
                          },
                          onSaved: (v) => _port = int.tryParse(v ?? '') ?? 1080,
                        ),
                        const SizedBox(height: 12),
                        // Username
                        TextFormField(
                          initialValue: _username,
                          decoration: const InputDecoration(labelText: 'Username (optional)'),
                          onSaved: (v) => _username = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        // Password
                        TextFormField(
                          initialValue: _password,
                          decoration: InputDecoration(
                            labelText: 'Password (optional)',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          onSaved: (v) => _password = v ?? '',
                        ),
                        const SizedBox(height: 16),
                        // Password Mode
                        DropdownButtonFormField<String>(
                          value: _passwordMode,
                          decoration: const InputDecoration(labelText: 'Password Mode'),
                          items: const [
                            DropdownMenuItem(value: 'persistent', child: Text('Persistent')),
                            DropdownMenuItem(value: 'one-time', child: Text('One-time (clears on switch)')),
                            DropdownMenuItem(value: 'timed', child: Text('Timed (auto-expires)')),
                          ],
                          onChanged: (v) => setState(() => _passwordMode = v!),
                        ),
                        if (_passwordMode == 'timed') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: _passwordTTLMinutes.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Expires after (minutes)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final m = int.tryParse(v ?? '');
                              if (m == null || m < 1) return 'Must be at least 1 minute';
                              return null;
                            },
                            onSaved: (v) => _passwordTTLMinutes = int.tryParse(v ?? '') ?? 60,
                          ),
                        ],
                        if (isEditing) ...[
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _lockOnSave,
                            onChanged: (v) => setState(() => _lockOnSave = v ?? false),
                            title: const Text(
                              'Lock password after saving',
                              style: TextStyle(fontSize: 13, color: Colors.red),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEditing ? 'Save' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
