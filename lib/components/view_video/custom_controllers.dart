import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/ad_components/ad_labels.dart';
import 'package:streamit_flutter/components/ad_components/ad_services.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

///Center Controllers
class VideoPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onReplay10;
  final VoidCallback? onForward10;
  final bool isLive;

  const VideoPlayerControls({Key? key, required this.isPlaying, required this.onPlayPause, this.onReplay10, this.onForward10, this.isLive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isLive) IconButton(icon: const Icon(Icons.replay_10, color: Colors.white), onPressed: onReplay10),
        IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white, size: 40), onPressed: onPlayPause),
        if (!isLive) IconButton(icon: const Icon(Icons.forward_10, color: Colors.white), onPressed: onForward10),
      ],
    );
  }
}

//region Video Player Controllers
///Bottom Controllers
class VideoPlayerBottomBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final List<Duration> adBreaks;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onFullscreenToggle;
  final VoidCallback onUserInteraction;
  final bool isLive;

  const VideoPlayerBottomBar({
    Key? key,
    required this.position,
    required this.duration,
    required this.adBreaks,
    required this.onSeek,
    this.onFullscreenToggle,
    required this.onUserInteraction,
    this.isLive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomProgressBar(
              position: position,
              duration: duration,
              adBreaks: adBreaks,
              isAdPlaying: false,
              isLive: isLive,
              onSeek: (duration) {
                onSeek(duration);
                onUserInteraction();
              },
            ),
          ),
          isLive
              ? LiveTagComponent()
              : Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.fullscreen, size: 20),
            onPressed: () {
              onFullscreenToggle?.call();
              onUserInteraction();
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Custom Progress bar with ad break indicators
class CustomProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final List<Duration> adBreaks;
  final bool isAdPlaying;
  final bool isLive;
  final void Function(Duration)? onSeek;

  const CustomProgressBar({super.key, required this.position, required this.duration, required this.adBreaks, this.isAdPlaying = false, this.isLive = false, this.onSeek});

  @override
  Widget build(BuildContext context) {
    final double progress = isLive ? 1.0 : (duration.inSeconds == 0 ? 0 : position.inSeconds / duration.inSeconds);
    final barColor = colorPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbWidth = 8.0;
        final actualBarWidth = constraints.maxWidth - thumbWidth;

        void handleSeek(Offset localPosition) {
          if (isLive) return;
          final dx = localPosition.dx - thumbWidth / 2;
          final percent = (dx / actualBarWidth).clamp(0.0, 1.0);
          final newSeconds = (duration.inSeconds * percent).round();
          if (onSeek != null) {
            onSeek!(Duration(seconds: newSeconds));
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: isLive
              ? null
              : (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  handleSeek(localPosition);
                },
          onTapDown: isLive
              ? null
              : (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  handleSeek(localPosition);
                },
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                _buildBackgroundBar(),
                if (!isAdPlaying && !isLive) _buildThumb(progress, actualBarWidth, barColor),
                if (!isLive) ..._buildAdBreakIndicators(actualBarWidth),
                _buildProgressBar(progress, barColor),
              ],
            ),
          ),
        );
      },
    );
  }

//region Helper Widgets
  /// Builds the background bar for the progress indicator.
  Widget _buildBackgroundBar() {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Builds the thumb indicator for the current position in the progress bar.
  Widget _buildThumb(double progress, double actualBarWidth, Color barColor) {
    return Positioned(
      left: (progress.clamp(0.0, 1.0) * actualBarWidth) - 4,
      top: 0,
      bottom: 0,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
      ),
    );
  }

  /// Builds the progress bar that visually represents the current playback position.
  Widget _buildProgressBar(double progress, Color barColor) {
    return FractionallySizedBox(
      widthFactor: progress.clamp(0.0, 1.0),
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Builds indicators for ad breaks within the progress bar.
  List<Widget> _buildAdBreakIndicators(double actualBarWidth) {
    return adBreaks.where((adBreak) => adBreak > Duration.zero && adBreak < duration).map((adBreak) {
      if (duration.inMilliseconds == 0) return const SizedBox();

      final adPosition = adBreak.inMilliseconds / duration.inMilliseconds;
      final clamped = adPosition.clamp(0.0, 1.0);
      final left = clamped * actualBarWidth;

      return Positioned(
        left: left,
        top: 0,
        bottom: 0,
        child: Container(
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }).toList();
  }

//endregion
}
//endregion

//region Ad Player Controllers
/// Ad Player Controllers with Skip and Progress Bar
class AdPlayerControllers extends StatelessWidget {
  final AdStateNotifier adState;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool isFullscreen;
  final VoidCallback onSkip;
  final bool showControls;
  final VoidCallback onUserInteraction;

  const AdPlayerControllers({
    Key? key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    this.progressColor,
    this.backgroundColor,
    this.isFullscreen = false,
    required this.adState,
    required this.onSkip,
    required this.showControls,
    required this.onUserInteraction,
  }) : super(key: key);

  bool _shouldShowSkipButton() {
    final ad = adState.currentAd;
    if (ad == null) return false;
    if (ad.isHtmlAd && (ad.overlay == true || ad.isCompanionAd)) {
      return false;
    }
    final shouldShow = adState.isAdPlaying && ad.canBeSkipped && ad.type?.toLowerCase() != 'vast';
    return shouldShow;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUserInteraction,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showControls)
            Center(
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.black87,
                  size: 40,
                ),
                onPressed: () {
                  onPlayPause();
                  onUserInteraction();
                },
              ),
            ),
          if (showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AdProgressBarWidget(
                        position: position,
                        duration: duration,
                        progressColor: Colors.yellow,
                        backgroundColor: backgroundColor,
                        margin: EdgeInsets.zero,
                        height: 3.0,
                      ),
                    ),
                    8.width,
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AdLabel(isFullscreen: isFullscreen),
          if (_shouldShowSkipButton())
            AdSkipButton(
              isFullscreen: isFullscreen,
              isSkippable: adState.isSkippable,
              skipCountdown: adState.adSkipCountdown,
              onSkip: onSkip,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Standalone Ad Progress Bar Widget - Can be positioned anywhere
class AdProgressBarWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Color? progressColor;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final double height;

  const AdProgressBarWidget({
    Key? key,
    required this.position,
    required this.duration,
    this.progressColor,
    this.backgroundColor,
    this.margin,
    this.height = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = duration.inSeconds == 0 ? 0 : position.inSeconds / duration.inSeconds;

    final barColor = progressColor ?? Colors.white;
    final bgColor = backgroundColor ?? Colors.white.withValues(alpha: 0.3);

    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Background bar
          Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          // Progress bar
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//endregion
