import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/model/app.dart';
import 'package:lux/tr.dart';
import 'package:provider/provider.dart';

class ProxyItemActionMenu extends StatefulWidget {
  final void Function(ProxyItemAction action) onClick;
  final MenuController controller;
  final String id;

  const ProxyItemActionMenu({
    super.key,
    required this.controller,
    required this.onClick,
    required this.id,
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
    return Consumer<AppStateModel>(builder: (context, appState, child) {
      final isDeleteDisabled =
          !appState.isStarted && appState.selectedProxyId == widget.id;
      return MenuAnchor(
          childFocusNode: buttonFocusNode,
          controller: widget.controller,
          menuChildren: <Widget>[
            MenuItemButton(
                onPressed: () {
                  widget.onClick(ProxyItemAction.edit);
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
                onPressed: isDeleteDisabled
                    ? null
                    : () => widget.onClick(ProxyItemAction.delete),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: isDeleteDisabled
                          ? null
                          : Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      tr().delete,
                      style: isDeleteDisabled
                          ? null
                          : TextStyle(
                              color: Theme.of(context).colorScheme.error),
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
    });
  }
}
