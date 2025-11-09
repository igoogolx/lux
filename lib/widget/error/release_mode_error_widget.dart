import 'package:flutter/material.dart';
import 'package:lux/widget/error/core_run_error_handler.dart';

import '../../error.dart';

const corePathVar = "LUX_CORE_PATH";

class ReleaseModeErrorWidget extends StatelessWidget {
  const ReleaseModeErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (details.exception is CoreRunError) {
      return CoreRunErrorHandler(
          errorDetail: details.exception as CoreRunError);
    }
    return Center(
      child: Text(
        details.exception.toString(),
        style: const TextStyle(color: Colors.yellow, fontSize: 16),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
