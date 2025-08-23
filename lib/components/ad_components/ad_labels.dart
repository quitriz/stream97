import 'package:flutter/material.dart';
import 'package:streamit_flutter/main.dart';

///Advertisement label widget
class AdLabel extends StatelessWidget {
  final bool isFullscreen;

  const AdLabel({Key? key, required this.isFullscreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Positioned(
      top: isFullscreen ? (isLandscape ? 24 : 16) : 12,
      left: isFullscreen ? (isLandscape ? 24 : 16) : 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
        child: Text(
          language.advertisement,
          style: TextStyle(color: Colors.white, fontSize: isFullscreen ? 16 : 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Skip button widget for ads
class AdSkipButton extends StatelessWidget {
  final bool isFullscreen;
  final bool isSkippable;
  final int skipCountdown;
  final VoidCallback onSkip;

  const AdSkipButton({Key? key, required this.isFullscreen, required this.isSkippable, required this.skipCountdown, required this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    double bottomPosition = isFullscreen ? (isLandscape ? 24 : 20) : 16;
    double rightPosition = isFullscreen ? (isLandscape ? 24 : 16) : 12;

    return Positioned(
      bottom: bottomPosition,
      right: rightPosition,
      child: GestureDetector(
        onTap: onSkip,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isFullscreen ? 14 : 10, vertical: isFullscreen ? 10 : 6),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
          child: Text(
            isSkippable ? language.skipAd : '${language.skipIn} ${skipCountdown}s',
            style: TextStyle(color: Colors.white, fontSize: isFullscreen ? 16 : 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
