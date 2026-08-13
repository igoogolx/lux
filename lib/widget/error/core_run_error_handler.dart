import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lux/tr.dart';
import 'package:lux/util/elevate.dart';
import 'package:path/path.dart' as path;

import '../../const/const.dart';
import '../../error.dart';

const corePathVar = "LUX_CORE_PATH";

class CoreRunErrorHandler extends StatefulWidget {
  final CoreRunError errorDetail;

  const CoreRunErrorHandler({
    super.key,
    required this.errorDetail,
  });

  @override
  State<CoreRunErrorHandler> createState() => _CoreRunErrorHandlerState();
}

class _CoreRunErrorHandlerState extends State<CoreRunErrorHandler> {
  var isElevated = false;
  var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);

  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS) {
      getFileOwner(corePath).then((owner) {
        setState(() {
          isElevated = owner == "root";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsetsGeometry.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        tr().somethingWrong,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const Divider(),
                  SelectableText(
                    "${tr().coreRunError}:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    margin: EdgeInsetsGeometry.only(top: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).dividerColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    child: SelectableText(widget.errorDetail.message),
                  )
                ],
              ),
            ),
            (!Platform.isMacOS || isElevated)
                ? SizedBox()
                : Container(
                    margin: EdgeInsetsGeometry.only(bottom: 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.handyman,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              tr().howToFix,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const Divider(),
                        SelectableText(
                          tr().elevateCoreStep,
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          margin: EdgeInsetsGeometry.only(top: 8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).dividerColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 4),
                          child: SelectableText(
                              "export $corePathVar=$corePath\n\nsudo chown root:wheel \$$corePathVar\n\nsudo chmod 770 \$$corePathVar\n\nsudo chmod +sx \$$corePathVar"),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    ));
  }
}
