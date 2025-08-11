import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_controllers.dart';

class CustomPodPlayerControlOverlay extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final List<Duration> adBreaks;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onReplay10;
  final VoidCallback? onForward10;
  final VoidCallback? onFullscreenToggle;
  final Widget? overlayAd;
  final bool isLive;

  const CustomPodPlayerControlOverlay({
    super.key,
    required this.position,
    required this.duration,
    required this.adBreaks,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeek,
    this.onReplay10,
    this.onForward10,
    this.onFullscreenToggle,
    this.overlayAd,
    this.isLive = false,
  });

  @override
  State<CustomPodPlayerControlOverlay> createState() => _CustomPodPlayerControlOverlayState();
}

class _CustomPodPlayerControlOverlayState extends State<CustomPodPlayerControlOverlay> {
  bool isVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        isVisible = false;
      });
    });
  }

  void _onUserInteraction() {
    setState(() {
      isVisible = true;
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onUserInteraction,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayerControls(
                  isPlaying: widget.isPlaying,
                  isLive: widget.isLive,
                  onPlayPause: () {
                    widget.onPlayPause();
                    _onUserInteraction();
                  },
                  onReplay10: () {
                    widget.onReplay10?.call();
                    _onUserInteraction();
                  },
                  onForward10: () {
                    widget.onForward10?.call();
                    _onUserInteraction();
                  },
                ),
                VideoPlayerBottomBar(
                  position: widget.position,
                  duration: widget.duration,
                  adBreaks: widget.adBreaks,
                  onSeek: widget.onSeek,
                  onFullscreenToggle: widget.onFullscreenToggle,
                  onUserInteraction: _onUserInteraction,
                  isLive: widget.isLive,
                ),
              ],
            ),
          ),
        ),
        widget.overlayAd ?? const SizedBox.shrink(),
      ],
    );
  }
}
