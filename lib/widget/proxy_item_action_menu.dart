import 'package:flutter/material.dart';
import 'package:lux/tr.dart';

class ProxyItemActionMenu extends StatefulWidget {
  final Function onDelete;
  final Function onEdit;
  final MenuController controller;

  const ProxyItemActionMenu({
    super.key,
    required this.onDelete,
    required this.controller,
    required this.onEdit,
  });

  @override
  State<ProxyItemActionMenu> createState() => _ProxyItemActionMenuState();
}

class _ProxyItemActionMenuState extends State<ProxyItemActionMenu> {
  FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  @override
  void dispose() {
    super.dispose();
    buttonFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
        childFocusNode: buttonFocusNode,
        controller: widget.controller,
        menuChildren: <Widget>[
          MenuItemButton(
              onPressed: () {
                widget.onEdit();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(tr().edit)
                ],
              )),
          MenuItemButton(
              onPressed: () {
                widget.onDelete();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    tr().delete,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  )
                ],
              )),
        ],
        builder: (_, MenuController controller, Widget? child) {
          return IconButton(
            focusNode: buttonFocusNode,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_horiz),
          );
        });
  }
}
