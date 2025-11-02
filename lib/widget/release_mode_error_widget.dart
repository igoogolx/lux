import 'package:flutter/material.dart';

class ReleaseModeErrorWidget extends StatelessWidget {
  const ReleaseModeErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${details.exception}',
        style: const TextStyle(color: Colors.yellow, fontSize: 16),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
