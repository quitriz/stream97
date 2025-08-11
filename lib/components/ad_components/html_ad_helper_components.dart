import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:streamit_flutter/utils/common.dart';

/// Base class for ad content parsing
class AdContentParser {
  static final Map<String, RegExp> _regexCache = {
    'image': RegExp(r'<img src="(.*?)"', dotAll: true),
    'title': RegExp(r'<h5 class="title">\s*(.*?)\s*</h5>', dotAll: true),
    'description': RegExp(r'<p class="desc">\s*(.*?)\s*</p>', dotAll: true),
    'buttonText': RegExp(r'<a href=".*?".*?>\s*(.*?)\s*</a>', dotAll: true),
    'buttonUrl': RegExp(r'<a href="(.*?)"', dotAll: true),
  };

  static String extractImageUrl(String htmlContent) {
    return _regexCache['image']!.firstMatch(htmlContent)?.group(1)?.trim() ?? '';
  }

  static String extractTitle(String htmlContent) {
    return _regexCache['title']!.firstMatch(htmlContent)?.group(1)?.trim() ?? 'Limited Time Offer';
  }

  static String extractDescription(String htmlContent) {
    return _regexCache['description']!.firstMatch(htmlContent)?.group(1)?.trim() ?? 'Don\'t miss this special offer.';
  }

  static String extractButtonText(String htmlContent) {
    return _regexCache['buttonText']!.firstMatch(htmlContent)?.group(1)?.trim() ?? 'Subscribe Now';
  }

  static String extractButtonUrl(String htmlContent) {
    return _regexCache['buttonUrl']!.firstMatch(htmlContent)?.group(1)?.trim() ?? '';
  }
}

/// Mixin for countdown timer functionality
mixin CountdownTimerMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  int _currentCountdown = 0;

  int get skipDuration;

  VoidCallback? get onTimerComplete;

  int get currentCountdown => _currentCountdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _currentCountdown = skipDuration;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentCountdown--;
        });

        if (_currentCountdown <= 0) {
          timer.cancel();
          onTimerComplete?.call();
        }
      } else {
        timer.cancel();
      }
    });
  }
}

/// Common ad button widget
class AdButton extends StatelessWidget {
  final String text;
  final String url;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;

  const AdButton({
    Key? key,
    required this.text,
    required this.url,
    this.fontSize = 9,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 4
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          appLaunchUrl(url, forceWebView: true);
        }
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(borderRadius)),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Common countdown display widget
class CountdownDisplay extends StatelessWidget {
  final int countdown;
  final double fontSize;
  final Color backgroundColor;
  final EdgeInsets padding;

  const CountdownDisplay({
    Key? key,
    required this.countdown,
    this.fontSize = 9,
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4)),
      child: Text(
        '$countdown',
        style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Optimized cached network image widget
class AdImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AdImage({Key? key, required this.imageUrl, this.width, this.height, this.fit = BoxFit.contain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(width: width, height: height, color: Colors.transparent),
      errorWidget: (context, url, error) => SizedBox(width: width, height: height),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
