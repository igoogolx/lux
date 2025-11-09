import 'package:flutter/material.dart';
import 'package:lux/widget/proxy_item_action_menu.dart';

import '../core/core_config.dart';

class ProxyListItem extends StatefulWidget {
  final ProxyItem item;
  final Function onDelete;
  final Function onEdit;
  const ProxyListItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ProxyListItem> createState() => _ProxyListItemState();
}

class _ProxyListItemState extends State<ProxyListItem> {
  final menuController = MenuController();

  FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  @override
  void dispose() {
    super.dispose();
    buttonFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return RadioListTile<String>(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name.isNotEmpty
                    ? item.name
                    : "${item.server}:${item.port}",
                style: TextStyle(fontSize: 14),
              ),
              Text(
                item.type,
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          ProxyItemActionMenu(
            onDelete: widget.onDelete,
            onEdit: widget.onEdit,
            controller: menuController,
          )
        ],
      ),
      value: item.id,
    );
  }
}
