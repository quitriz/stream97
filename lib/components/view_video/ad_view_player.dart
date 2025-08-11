import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/components/ad_components/ad_services.dart';
import 'package:streamit_flutter/components/ad_components/html_ad_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'custom_controllers.dart';

class AdViewPlayer extends StatefulWidget {
  final AdStateNotifier adState;
  final bool isFullscreen;
  final PodPlayerController? adController;
  final VoidCallback onSkip;

  const AdViewPlayer({
    Key? key,
    required this.adState,
    required this.isFullscreen,
    required this.adController,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<AdViewPlayer> createState() => _AdViewPlayerState();
}

class _AdViewPlayerState extends State<AdViewPlayer> {
  bool _showControls = false;
  Timer? _hideTimer;
  static const int _controlsHideDuration = 3;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onUserInteraction() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: _controlsHideDuration), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetControlsTimer() {
    _hideTimer?.cancel();
    if (_showControls) {
      _hideTimer = Timer(const Duration(seconds: _controlsHideDuration), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 235,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: const ValueKey('ad'),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: PodVideoPlayer(
                controller: widget.adController!,
                alwaysShowProgressBar: false,
                overlayBuilder: (options) => AdPlayerControllers(
                  adState: widget.adState,
                  onSkip: widget.onSkip,
                  isPlaying: widget.adController?.isVideoPlaying ?? false,
                  position: widget.adController?.videoPlayerValue?.position ??
                      Duration.zero,
                  duration: widget.adController?.videoPlayerValue?.duration ??
                      Duration.zero,
                  isFullscreen: widget.isFullscreen,
                  showControls: _showControls,
                  onUserInteraction: _onUserInteraction,
                  onPlayPause: () {
                    if (widget.adController?.isVideoPlaying ?? false) {
                      widget.adController?.pause();
                    } else {
                      widget.adController?.play();
                    }
                    _resetControlsTimer();
                  },
                  progressColor: Colors.yellow,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          if (widget.adState.isAdPlaying &&
              widget.adState.currentAd?.isOverlayAd == true)
            OverlayAd(
              content: widget.adState.currentAd?.content.validate() ?? '',
              isFullscreen: widget.isFullscreen,
              skipDuration: widget.adState.currentAd?.skipDuration,
              onTimerComplete: () {
                widget.adState.reset();
              },
            ),
          if (widget.adState.isAdPlaying &&
              widget.adState.currentAd?.isCompanionAd == true)
            CompanionAd(
              content: widget.adState.currentAd?.content.validate() ?? '',
              isFullscreen: widget.isFullscreen,
              skipDuration: widget.adState.currentAd?.skipDuration,
              onTimerComplete: () {
                widget.adState.reset();
              },
            ),
        ],
      ),
    );
  }
}
