import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/ad_components/html_ad_helper_components.dart';

/// Overlay Ad Widget
class OverlayAd extends StatefulWidget {
  final String content;
  final bool isFullscreen;
  final int? skipDuration;
  final VoidCallback? onTimerComplete;

  const OverlayAd({Key? key, required this.content, required this.isFullscreen, this.skipDuration, this.onTimerComplete}) : super(key: key);

  @override
  State<OverlayAd> createState() => _OverlayAdState();
}

class _OverlayAdState extends State<OverlayAd> with CountdownTimerMixin {
  @override
  int get skipDuration => widget.skipDuration ?? 5;

  @override
  VoidCallback? get onTimerComplete => widget.onTimerComplete;

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrl = AdContentParser.extractImageUrl(widget.content);
    final title = AdContentParser.extractTitle(widget.content);
    final description = AdContentParser.extractDescription(widget.content);
    final buttonText = AdContentParser.extractButtonText(widget.content);
    final buttonUrl = AdContentParser.extractButtonUrl(widget.content);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 60),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Row(
              children: [
                AdImage(imageUrl: imageUrl, width: 40, height: 15).paddingAll(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: widget.isFullscreen ? 12 : 10, fontWeight: FontWeight.bold, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ).flexible(),
                      2.height,
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[400], fontSize: widget.isFullscreen ? 10 : 9, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ).flexible(),
                    ],
                  ).paddingSymmetric(vertical: 8, horizontal: 4),
                ),
                AdButton(text: buttonText, url: buttonUrl, fontSize: 9).paddingOnly(left: 8, top: 12, right: 24, bottom: 12),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: CountdownDisplay(countdown: currentCountdown),
            ),
          ],
        ),
      ),
    );
  }
}

/// Companion Ad Widget
class CompanionAd extends StatefulWidget {
  final String content;
  final bool isFullscreen;
  final int? skipDuration;
  final VoidCallback? onTimerComplete;

  const CompanionAd({Key? key, required this.content, required this.isFullscreen, this.skipDuration, this.onTimerComplete}) : super(key: key);

  @override
  State<CompanionAd> createState() => _CompanionAdState();
}

class _CompanionAdState extends State<CompanionAd> with CountdownTimerMixin {
  @override
  int get skipDuration => widget.skipDuration ?? 5;

  @override
  VoidCallback? get onTimerComplete => widget.onTimerComplete;

  double _calculateAdSize(double screenWidth) {
    if (screenWidth > 1200) return 180;
    if (screenWidth > 600) return 160;
    return (screenWidth * 0.35).clamp(120, 140);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final adSize = _calculateAdSize(screenWidth);

    final imageUrl = AdContentParser.extractImageUrl(widget.content);
    final title = AdContentParser.extractTitle(widget.content);
    final description = AdContentParser.extractDescription(widget.content);
    final buttonText = AdContentParser.extractButtonText(widget.content);
    final buttonUrl = AdContentParser.extractButtonUrl(widget.content);

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, widget.isFullscreen ? MediaQuery.of(context).padding.top + 8 : 16, 8, 0),
        child: Container(
          width: adSize,
          height: adSize,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: adSize * 0.15,
                child: Row(
                  children: [
                    AdImage(imageUrl: imageUrl, height: adSize * 0.12),
                    const Spacer(),
                    CountdownDisplay(countdown: currentCountdown, fontSize: 9),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: adSize * 0.085, fontWeight: FontWeight.bold, height: 1.1),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),
                    SizedBox(height: adSize * 0.04),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[400], fontSize: adSize * 0.055, height: 1.2),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
              AdButton(text: buttonText, url: buttonUrl, fontSize: adSize * 0.065, padding: EdgeInsets.symmetric(vertical: adSize * 0.04), borderRadius: 4),
            ],
          ).paddingAll(adSize * 0.06),
        ),
      ),
    );
  }
}
