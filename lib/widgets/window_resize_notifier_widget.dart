import 'package:flutter/material.dart';

class WindowResizeNotifierWidget extends StatelessWidget {
  const WindowResizeNotifierWidget({
    super.key,
    required this.onWindowResizedCallback,
    this.child,
  });

  final Function(Size) onWindowResizedCallback;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (SizeChangedLayoutNotification notification) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        final windowSize = Size(width, height);
        onWindowResizedCallback(windowSize);

        return true;
      },
      child: SizeChangedLayoutNotifier(child: child ?? const Placeholder()),
    );
  }
}
