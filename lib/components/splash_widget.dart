import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SplashWidget extends StatelessWidget {
  final double borderRadius;
  final Color color;
  final Color backgroundColor;
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;
  final GestureLongPressCallback? onLongPress;

  SplashWidget({
    Key? key,
    this.borderRadius = 16,
    this.color = Colors.white,
    this.backgroundColor = Colors.white,
    required this.child,
    required this.onTap,
    this.padding,
    this.hasShadow = false,
    this.onLongPress,
  }) : super(key: key);

  /// Local variable
  bool isTap = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, uptState) {
      return GestureDetector(
        onTap: () => onTap.call(),
        onTapDown: (s) {
          uptState(() {
            isTap = true;
          });
        },
        onTapUp: (s) {
          uptState(() {
            isTap = false;
          });
        },
        onLongPress: () {
          onLongPress?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding ?? EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: isTap ? color : Colors.transparent, width: 0.2),
              boxShadow: hasShadow ? [BoxShadow(color: Color(0xFF484848), blurRadius: 2.0)] : null),
          child: child,
        ),
      );
    });
  }
}
