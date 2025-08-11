import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:xml/xml.dart' as xml;
import '../../utils/constants.dart';

///Ad Services for handling ad parsing, scheduling, and playback
class AdService {
  static Future<String?> parseVastAd(String vastUrl) async {
    return await VastParser.parseBestVideoUrl(vastUrl);
  }

  static List<Duration> calculateAdBreaks(AdConfiguration? config, Duration totalDuration) {
    final List<Duration> adBreaks = [];
    final interval = int.tryParse(config?.midRollInterval?.toString() ?? '0') ?? 0;
    final midRollAds = config?.midRollAdsList ?? [];

    if (interval > 0 && midRollAds.isNotEmpty) {
      for (int i = 1; i * interval < totalDuration.inSeconds; i++) {
        if (i <= midRollAds.length) {
          adBreaks.add(Duration(seconds: i * interval));
        }
      }
    }
    return adBreaks;
  }

  static bool shouldPlayMidRollAds(AdConfiguration? config) {
    final midRollAds = config?.midRollAdsList ?? [];
    final interval = int.tryParse(config?.midRollInterval?.toString() ?? '0') ?? 0;
    return config?.midRollDisplay.validate() == true && midRollAds.isNotEmpty && interval > 0;
  }
}

///Vast Parser for extracting video URLs from VAST XML
class VastParser {
  static Future<String?> parseBestVideoUrl(String vastUrl) async {
    try {
      final response = await http.get(Uri.parse(vastUrl));
      if (response.statusCode != 200) return null;

      final doc = xml.XmlDocument.parse(response.body);
      final mediaFiles = doc.findAllElements('MediaFile');

      final mp4Files = _extractMp4Files(mediaFiles);
      if (mp4Files.isEmpty) return null;

      mp4Files.sort((a, b) => b['bitrate']!.compareTo(a['bitrate']!));
      return mp4Files.first['url'];
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> _extractMp4Files(Iterable<xml.XmlElement> mediaFiles) {
    return mediaFiles.where((e) => e.getAttribute('type') == 'video/mp4').map((e) {
      final bitrate = int.tryParse(e.getAttribute('bitrate') ?? '') ?? 0;
      final url = e.innerText.trim().replaceAll('<![CDATA[', '').replaceAll(']]>', '');
      return {'bitrate': bitrate, 'url': url};
    }).toList();
  }
}

/// Timer Service for managing ad skip and mid-roll timers
class TimerService {
  Timer? _adSkipTimer;
  Timer? _midRollTimer;

  void startSkipTimer(int seconds, VoidCallback onTick) {
    _adSkipTimer?.cancel();
    _adSkipTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => onTick(),
    );
  }

  void startMidRollTimer(int intervalSeconds, VoidCallback onTick) {
    _midRollTimer?.cancel();
    _midRollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) {
        onTick();
      },
    );
  }

  void cancelAllTimers() {
    _adSkipTimer?.cancel();
    _midRollTimer?.cancel();
  }

  void dispose() {
    cancelAllTimers();
  }
}

///AdStateNotifier for managing ad playback state
class AdStateNotifier extends ChangeNotifier {
  bool _isAdPlaying = false;
  bool _isSkippable = false;
  bool _showAdLabel = false;
  int _midRollIndex = 0;
  int _adSkipCountdown = 0;
  AdUnit? _currentAd;

  // Getters
  bool get isAdPlaying => _isAdPlaying;

  bool get isSkippable => _isSkippable;

  bool get showAdLabel => _showAdLabel;

  int get midRollIndex => _midRollIndex;

  int get adSkipCountdown => _adSkipCountdown;

  AdUnit? get currentAd => _currentAd;

  void startAd(AdUnit ad) {
    _isAdPlaying = true;
    _showAdLabel = true;
    _isSkippable = false;
    _currentAd = ad;
    notifyListeners();
  }

  void reset() {
    _isAdPlaying = false;
    _isSkippable = false;
    _showAdLabel = false;
    _currentAd = null;
    notifyListeners();
  }

  void setCurrentAd(AdUnit ad) {
    _currentAd = ad;
    notifyListeners();
  }

  void incrementMidRollIndex() {
    _midRollIndex++;
    notifyListeners();
  }

  void startSkipCountdown(int seconds) {
    _adSkipCountdown = seconds;
    notifyListeners();
  }

  void decrementSkipCountdown() {
    _adSkipCountdown--;
    notifyListeners();
  }

  void enableSkip() {
    _isSkippable = true;
    notifyListeners();
  }
}

/// VideoPlayerConfig for configuring video player behavior
class VideoPlayerConfig {
  final bool autoPlay;
  final bool showControls;
  final Duration skipDelay;
  final Duration hideControlsDelay;
  final bool enableGestures;

  const VideoPlayerConfig({
    this.autoPlay = false,
    this.showControls = true,
    this.skipDelay = const Duration(seconds: 5),
    this.hideControlsDelay = const Duration(seconds: 3),
    this.enableGestures = true,
  });

  VideoPlayerConfig copyWith({
    bool? autoPlay,
    bool? showControls,
    Duration? skipDelay,
    Duration? hideControlsDelay,
    bool? enableGestures,
  }) {
    return VideoPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      showControls: showControls ?? this.showControls,
      skipDelay: skipDelay ?? this.skipDelay,
      hideControlsDelay: hideControlsDelay ?? this.hideControlsDelay,
      enableGestures: enableGestures ?? this.enableGestures,
    );
  }
}

/// VideoPlayerLifecycleMixin for managing video player lifecycle events
mixin VideoPlayerLifecycleMixin<T extends StatefulWidget> on State<T> {
  late final List<Timer> _timers = [];
  late final List<PodPlayerController> _controllers = [];

  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  void registerController(PodPlayerController controller) {
    _controllers.add(controller);
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();

    super.dispose();
  }
}

//region Ad Helper Classes

///PerformanceMonitor for tracking operation durations
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void startTimer(String operation) {
    _stopwatches[operation] = Stopwatch()..start();
  }

  static void endTimer(String operation) {
    final stopwatch = _stopwatches[operation];
    if (stopwatch != null) {
      stopwatch.stop();
      log('$operation took ${stopwatch.elapsedMilliseconds}ms');
      _stopwatches.remove(operation);
    }
  }
}

///VideoPlayerException for handling video player errors
class VideoPlayerException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const VideoPlayerException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'VideoPlayerException: $message${code != null ? ' (Code: $code)' : ''}';
}

///ErrorHandler for managing errors in ad playback and video player
class ErrorHandler {
  static void handleAdError(dynamic error, AdUnit? ad, AdEventCallback? callback) {
    log('Ad Error: $error for ad: ${ad?.type}');
    callback?.call(AdEventType.adError, ad);
  }

  static void handlePlayerError(dynamic error, String context) {
    log('Player Error in $context: $error');
  }
}

//endregion