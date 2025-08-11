import 'package:flutter/material.dart';

class TrailerGestureDetector extends StatefulWidget {
  final Widget child;
  final Function() onTapOutsideCenter;
  final Function() onTapCenter;
  final bool isVimeo;

  TrailerGestureDetector({required this.child, required this.onTapOutsideCenter, required this.onTapCenter, this.isVimeo = false});

  @override
  _TrailerGestureDetectorState createState() => _TrailerGestureDetectorState();
}

class _TrailerGestureDetectorState extends State<TrailerGestureDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final Offset tapPos = box.globalToLocal(details.globalPosition);

        final double centerX = box.size.width / 2;
        final double centerY = box.size.height / 2;
        final double tapX = tapPos.dx;
        final double tapY = tapPos.dy;
        final double centerAreaSize = 60.0;

        if (widget.isVimeo) {
          if (!(tapX <= centerAreaSize && tapY >= box.size.height - centerAreaSize)) {
            widget.onTapOutsideCenter();
          } else {}
        } else {
          if (!(tapX >= centerX - centerAreaSize / 2 && tapX <= centerX + centerAreaSize / 2 && tapY >= centerY - centerAreaSize / 2 && tapY <= centerY + centerAreaSize / 2)) {
            widget.onTapOutsideCenter();
          } else {
            widget.onTapCenter.call();
          }
        }
      },
      child: widget.child,
    );
  }
}