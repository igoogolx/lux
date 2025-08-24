import 'package:flutter/material.dart';

class AppProgressIndicator extends StatefulWidget {
  const AppProgressIndicator({super.key});

  @override
  State<AppProgressIndicator> createState() => _AppProgressIndicatorState();
}

class _AppProgressIndicatorState extends State<AppProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        semanticsLabel: 'Circular progress indicator',
      ),
    );
  }
}
