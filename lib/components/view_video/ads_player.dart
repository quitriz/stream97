import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/components/view_video/ad_view_player.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import '../../utils/constants.dart';
import '../ad_components/ad_services.dart';
import '../ad_components/html_ad_widget.dart';
import 'custom_pod_player_overlays.dart';
import '../../models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

class VideoPlayerConfig {
  final bool autoPlay;
  final bool showControls;
  final Duration skipDelay;

  const VideoPlayerConfig({this.autoPlay = false, this.showControls = true, this.skipDelay = const Duration(seconds: 5)});
}

class AdVideoPlayerWidget extends StatefulWidget {
  final String streamUrl;
  final AdConfiguration? adConfig;
  final String title;
  final VideoPlayerConfig playerConfig;
  final AdEventCallback? onAdEvent;
  final bool isLive;
  final PostType postType;


  const AdVideoPlayerWidget({Key? key, required this.streamUrl, this.adConfig, required this.title, this.playerConfig = const VideoPlayerConfig(), this.onAdEvent, this.isLive = false, required this.postType})
      : super(key: key);

  @override
  State<AdVideoPlayerWidget> createState() => _AdVideoPlayerWidgetState();
}

class _AdVideoPlayerWidgetState extends State<AdVideoPlayerWidget> with VideoPlayerLifecycleMixin {
  late final PodPlayerController _streamController;
  List<Widget> overlayWidgets = [];

  PodPlayerController? _adController;

  late final AdStateNotifier _adStateNotifier;

  late final TimerService _timerService;

  bool _isFullscreen = false;

  bool _midRollTimerStarted = false;

  bool _postRollAdShown = false;

  bool _isVideoAdPlaying = false;

  bool _adsOnlyMode = false;

  bool _adsCompleted = false;

  //endregion

//region Init
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _adsOnlyMode = widget.streamUrl.getURLType() == VideoType.typeYoutube;
    if (_adsOnlyMode) {
      _startAdsOnlyFlow();
    } else {
      _initializeStreamPlayer();
    }
  }

  void _initializeServices() {
    _adStateNotifier = AdStateNotifier();
    _timerService = TimerService();
    _adStateNotifier.addListener(_onAdStateChanged);
  }

  void _initializeStreamPlayer() {
    PerformanceMonitor.startTimer('stream_controller_init');

    _streamController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.streamUrl),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
      ),
    );

    registerController(_streamController);

    _streamController.initialise().then((_) {
      PerformanceMonitor.endTimer('stream_controller_init');
      if (mounted) {
        setState(() {});
        _playPreRollAdIfNeeded();
      }
    }).catchError((error) {
      ErrorHandler.handlePlayerError(error, 'stream_controller_init');
      if (mounted) setState(() {});
    });

    _streamController.addListener(_onStreamPlayerStateChanged);
  }

  Future<void> _startAdsOnlyFlow() async {
    try {
      if (widget.adConfig?.adsType == AdTypeConst.vast) {
        final vastUrl = widget.adConfig?.vastUrl;
        if (vastUrl.validate().isNotEmpty) {
          final vastAdUrl = await AdService.parseVastAd(vastUrl!);
          if (vastAdUrl.validate().isNotEmpty) {
            await _playVastVideoAd(vastAdUrl!);
            return;
          }
        }
        setState(() {
          _adsCompleted = true;
        });
        return;
      }

      final preAds = widget.adConfig?.preRollAdsList ?? [];
      if (preAds.isNotEmpty) {
        await _playVideoAd(preAds.first, AdType.preRoll);
        return;
      }

      setState(() {
        _adsCompleted = true;
      });
    } catch (error) {
      ErrorHandler.handleAdError(error, null, widget.onAdEvent);
      setState(() {
        _adsCompleted = true;
      });
    }
  }
  //endregion

  Future<void> _initializeAdController(String videoUrl) async {
    try {
      PerformanceMonitor.startTimer('ad_controller_init');
      _adController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(videoUrl),
        podPlayerConfig: PodPlayerConfig(autoPlay: true, isLooping: false),
      );
      registerController(_adController!);
      await _adController!.initialise();
      PerformanceMonitor.endTimer('ad_controller_init');
      Future.delayed(VideoPlayerConstants.adCheckInterval, () {
        if (mounted && _adController != null) {
          _adController!.play();
          _addAdControllerListener();
        }
      });
    } catch (error) {
      ErrorHandler.handleAdError(error, _adStateNotifier.currentAd, widget.onAdEvent);
    }
  }

//endregion

//region Ad State Change Handlers
  void _onAdStateChanged() {
    if (mounted) {
      setState(() {
        overlayWidgets.clear();
      });
    }
  }

  void _onStreamPlayerStateChanged() {
    try {
      if (_adsOnlyMode) return;
      final currentFullscreenState = _streamController.isFullScreen;
      if (_isFullscreen != currentFullscreenState) {
        setState(() {
          _isFullscreen = currentFullscreenState;
        });
      }

      if (_streamController.isInitialised && _streamController.isVideoPlaying) {
        _startMidRollTimerIfNeeded();
      }

      /// Post-roll ad logic: show when last 10 seconds remain

      if (_streamController.isInitialised && !_postRollAdShown) {
        final position = _streamController.currentVideoPosition;

        final duration = _streamController.totalVideoLength;

        final remaining = duration - position;

        if (duration.inSeconds > 0 && remaining.inSeconds <= 10) {
          _postRollAdShown = true;

          _playPostRollAdIfNeeded();
        }
      } else if (_streamController.isInitialised) {}
    } catch (error) {
      ErrorHandler.handlePlayerError(error, 'stream_player_state_change');
    }
  }

  void _resetAdState() {
    _timerService.cancelAllTimers();
    _adStateNotifier.reset();
    _midRollTimerStarted = false;
  }

//endregion

//region Ad Playback Logic

  Future<void> _playVastVideoAd(String videoUrl) async {
    final vastAd = AdUnit(type: AdTypeConst.vast, videoUrl: videoUrl, skipEnabled: false);
    _startVideoAd(vastAd);
    await _initializeAdController(videoUrl);
  }

  Future<void> _handleVastAd() async {
    final vastUrl = widget.adConfig?.vastUrl;
    if (vastUrl.validate().isNotEmpty) {
      PerformanceMonitor.startTimer('vast_parsing');
      final vastAdUrl = await AdService.parseVastAd(vastUrl!);
      PerformanceMonitor.endTimer('vast_parsing');

      if (vastAdUrl != null) {
        await _playVastVideoAd(vastAdUrl);
        return;
      } else {}
    }
    _streamController.play();
    Future.delayed(const Duration(seconds: 3), _startMidRollTimerIfNeeded);
  }

  Future<void> _playVideoAd(AdUnit ad, AdType adType) async {
    _startVideoAd(ad);
    if (ad.videoUrl.validate().isNotEmpty) {
      await _initializeAdController(ad.videoUrl.validate());
    }
  }

  void _startVideoAd(AdUnit ad) {
    _adStateNotifier.startAd(ad);
    _notifyAdEvent(AdEventType.adStarted, ad);
    if (ad.canBeSkipped) {
      _startSkipTimer(ad);
    }
  }

  Future<void> _playPreRollAdIfNeeded() async {
    try {
      if (widget.adConfig?.adsType == AdTypeConst.vast) {
        await _handleVastAd();
        return;
      }

      final preAds = widget.adConfig?.preRollAdsList ?? [];
      if (preAds.isNotEmpty) {
        _streamController.pause();
        await _playVideoAd(preAds.first, AdType.preRoll);
      } else {
        _streamController.play();
        Future.delayed(const Duration(seconds: 3), _startMidRollTimerIfNeeded);
      }
    } catch (error) {
      ErrorHandler.handleAdError(error, null, widget.onAdEvent);
      _streamController.play();
    }
  }

  Future<void> _playMidRollAd(AdUnit ad) async {
    _adStateNotifier.setCurrentAd(ad);
    try {
      if (ad.isVideoAd) {
        _streamController.pause();
        _isVideoAdPlaying = true;
        await _playVideoAd(ad, AdType.midRoll);
      } else if (ad.isHtmlAd) {
        _handleHtmlAd(ad);
      } else {
        _streamController.play();
      }
    } catch (error) {
      ErrorHandler.handleAdError(error, ad, widget.onAdEvent);
      _streamController.play();
    }
  }

  void _startMidRollTimerIfNeeded() {
    if (_midRollTimerStarted) {
      return;
    }
    if (!AdService.shouldPlayMidRollAds(widget.adConfig)) {
      return;
    }
    final interval = widget.adConfig?.midRollInterval;
    _timerService.startMidRollTimer(interval!, _handleMidRollTick);
    _midRollTimerStarted = true;
  }

  void _handleMidRollTick() {
    final midRollAds = widget.adConfig?.midRollAdsList ?? [];
    if (_isVideoAdPlaying) {
      return;
    }

    if (_adStateNotifier.midRollIndex < midRollAds.length) {
      final ad = midRollAds[_adStateNotifier.midRollIndex];

      _playMidRollAd(ad);

      _adStateNotifier.incrementMidRollIndex();
    } else {
      if (_adController?.isVideoPlaying == false) {
        _timerService.cancelAllTimers();
      }
    }
  }

  Future<void> _playPostRollAdIfNeeded() async {
    final postAds = widget.adConfig?.postRollAdsList ?? [];

    if (widget.adConfig?.postRollAdsList != null) {}

    if (widget.adConfig?.postRollDisplay == true && postAds.isNotEmpty) {
      final ad = postAds.first;
      _adStateNotifier.setCurrentAd(ad);

      try {
        if (ad.isVideoAd) {
          _streamController.pause();
          await _playVideoAd(ad, AdType.postRoll);
        } else if (ad.isHtmlAd) {
          _handleHtmlAd(ad);
        } else {
          _streamController.play();
        }
      } catch (error) {
        ErrorHandler.handleAdError(error, ad, widget.onAdEvent);
        _streamController.play();
      }
    } else {}
  }

  Future<void> _finishVideoAd() async {
    _notifyAdEvent(AdEventType.adFinished, _adStateNotifier.currentAd);
    _disposeAdController();
    _resetAdState();
    _isVideoAdPlaying = false;
    if (_adsOnlyMode) {
      if (mounted) {
        setState(() {
          _adsCompleted = true;
        });
      }
      return;
    }
    if (_isFullscreen && !_streamController.isFullScreen) {
      _streamController.enableFullScreen();
    }
    _streamController.play();
  }

  bool _shouldShowAdPlayer() {
    return _adStateNotifier.isAdPlaying && _adController != null && _adStateNotifier.currentAd?.isVideoAd == true;
  }

//endregion

//region HTML Ad Handling

  void _handleHtmlAd(AdUnit ad) {
    if (ad.isOverlayAd) {
      _showHtmlOverlayAd(ad);
    } else {
      _showHtmlCompanionAd(ad);
    }
  }

  void _startHtmlAd(AdUnit ad) {
    _adStateNotifier.startAd(ad);
    _notifyAdEvent(AdEventType.adStarted, ad);
    if (ad.canBeSkipped) {
      _startSkipTimer(ad);
    }
  }

  void _showHtmlOverlayAd(AdUnit ad) {
    _startHtmlAd(ad);
  }

  void _showHtmlCompanionAd(AdUnit ad) {
    _startHtmlAd(ad);
    _streamController.play();
  }

  void _finishHtmlAd() {
    if (!_adStateNotifier.isAdPlaying) {
      return;
    }

    _notifyAdEvent(AdEventType.adFinished, _adStateNotifier.currentAd);
    _resetAdState();

    overlayWidgets.clear();

    if (_adStateNotifier.currentAd?.isOverlayAd == true) {
      if (!_streamController.isVideoPlaying) {
        _streamController.play();
      }
    }
  }

//endregion

//region Ad Skip Logic

  void _startSkipTimer(AdUnit ad) {
    if (!ad.canBeSkipped) return;

    final skipDuration = ad.skipDurationAsDuration;
    _adStateNotifier.startSkipCountdown(ad.skipDurationInSeconds);
    _timerService.startSkipTimer(skipDuration.inSeconds, _handleSkipTick);
  }

  void _handleSkipTick() {
    if (_adStateNotifier.adSkipCountdown <= 0) {
      _adStateNotifier.enableSkip();
    } else {
      _adStateNotifier.decrementSkipCountdown();
    }
  }

  void skipAd() {
    if (!_adStateNotifier.isSkippable) return;
    _notifyAdEvent(AdEventType.adSkipped, _adStateNotifier.currentAd);
    final currentAd = _adStateNotifier.currentAd;
    if (currentAd?.isVideoAd == true) {
      _disposeAdController();
      _finishVideoAd();
    } else {
      _finishHtmlAd();
    }
  }

//endregion

//region Ad Helper Methods
  List<Duration> _getAllAdBreaks() {
    if (_adsOnlyMode) return const [];
    return AdService.calculateAdBreaks(widget.adConfig, _streamController.totalVideoLength);
  }

  void _addAdControllerListener() {
    _adController!.addListener(() async {
      if (_isAdNearCompletion()) {
        await _finishVideoAd();
      }
    });
  }

  void _notifyAdEvent(AdEventType type, AdUnit? ad) {
    widget.onAdEvent?.call(type, ad);
  }

  bool _isAdNearCompletion() {
    if (_adController == null) return false;
    final position = _adController!.currentVideoPosition;
    final duration = _adController!.totalVideoLength;
    return position.isNearTo(duration, threshold: Duration(seconds: VideoPlayerConstants.adCompletionThreshold));
  }

//endregion

//region Dispose
  void _disposeAdController() {
    _adController?.dispose();
    _adController = null;
  }

  @override
  void dispose() {
    _adStateNotifier.removeListener(_onAdStateChanged);
    _adStateNotifier.dispose();
    _timerService.dispose();
    super.dispose();
  }

//endregion

//region Overlay Widgets

  Widget _buildOverlay(BuildContext context) {
    final videoValue = _streamController.videoPlayerValue;
    final position = videoValue?.position ?? Duration.zero;
    final duration = videoValue?.duration ?? const Duration(seconds: 1);
    final allAdBreaks = _getAllAdBreaks();

    overlayWidgets.clear();

    final overlayAd = _buildOverlayAd();
    final companionAd = _buildCompanionAd();
    if (overlayAd != null) overlayWidgets.add(overlayAd);
    if (companionAd != null) overlayWidgets.add(companionAd);
    if (_shouldShowAdPlayer() && context.orientation == Orientation.landscape) {
      return _buildAdView();
    }

    return CustomPodPlayerControlOverlay(
      position: position,
      duration: duration,
      adBreaks: allAdBreaks,
      isPlaying: _streamController.isVideoPlaying,
      overlayAd: Stack(children: overlayWidgets),
      onFullscreenToggle: () {
        _streamController.isFullScreen ? _streamController.disableFullScreen(context) : _streamController.enableFullScreen();
      },
      onPlayPause: () {
        _streamController.isVideoPlaying ? _streamController.pause() : _streamController.play();
      },
      onSeek: widget.isLive ? (duration) {} : (duration) => _streamController.videoSeekTo(duration),
      onReplay10: widget.isLive
          ? null
          : () {
              final newPosition = Duration(seconds: (position.inSeconds - 10).clamp(0, duration.inSeconds));
              _streamController.videoSeekTo(newPosition);
            },
      onForward10: widget.isLive
          ? null
          : () {
              final newPosition = Duration(seconds: (position.inSeconds + 10).clamp(0, duration.inSeconds));
              _streamController.videoSeekTo(newPosition);
            },
      isLive: widget.isLive,
    );
  }

  Widget _buildAdView() {
    return AdViewPlayer(
      adState: _adStateNotifier,
      isFullscreen: _isFullscreen,
      adController: _adController,
      onSkip: skipAd,
    );
  }

  Widget? _buildOverlayAd() {
    final ad = _adStateNotifier.currentAd;

    if (_adStateNotifier.isAdPlaying && ad != null && ad.isOverlayAd) {
      final content = ad.content ?? '';
      if (content.trim().isEmpty) return null;

      return OverlayAd(
        content: content,
        isFullscreen: _isFullscreen,
        skipDuration: ad.skipDuration,
        onTimerComplete: () {
          _finishHtmlAd();
        },
      );
    }
    return null;
  }

  Widget? _buildCompanionAd() {
    final ad = _adStateNotifier.currentAd;

    if (_adStateNotifier.isAdPlaying && ad != null && ad.isCompanionAd) {
      final content = ad.content ?? '';
      if (content.trim().isEmpty) return null;

      return CompanionAd(
        content: content,
        isFullscreen: _isFullscreen,
        skipDuration: ad.skipDuration,
        onTimerComplete: () {
          _finishHtmlAd();
        },
      );
    }
    return null;
  }

//endregion

  @override
  Widget build(BuildContext context) {
    if (_adsOnlyMode) {
      if (_shouldShowAdPlayer() && !_adsCompleted) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: _buildAdView(),
        );
      }

      return VideoWidget(
        videoURL: widget.streamUrl,
        watchedTime: '',
          videoType: widget.postType,
        videoURLType: widget.streamUrl.getURLType(),
        videoId: 0,
        thumbnailImage: '',
        isTrailer: true,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: const ValueKey('stream'),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _shouldShowAdPlayer() ? 0.0 : 1.0,
              child: PodVideoPlayer(
                controller: _streamController,
                alwaysShowProgressBar: false,
                overlayBuilder: (options) => _buildOverlay(context),
              ),
            ),
          ),
          if (_shouldShowAdPlayer())
            Positioned.fill(
              child: _buildAdView(),
            ),
        ],
      ),
    );
  }
}
