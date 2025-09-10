import 'package:flutter/material.dart';

import '../core/core_config.dart';

class ProxyListItem extends StatelessWidget {
  final ProxyItem item;
  const ProxyListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(
        item.name.isNotEmpty ? item.name : "${item.server}:${item.port}",
        style: TextStyle(fontSize: 12),
      ),
      value: item.id,
    );
  }
}
