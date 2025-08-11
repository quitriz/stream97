import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import '../../config.dart';
import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../utils/common.dart';
import '../../utils/constants.dart';
import '../../utils/resources/colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final int videoId;
  final String videoURL;
  final String videoThumbnailImage;
  final String watchedTime;
  final PostType videoType;
  final String videoURLType;
  final bool isTrailer;
  final bool isFromDashboard;

  const VideoPlayerWidget({
    Key? key,
    required this.videoURL,
    required this.watchedTime,
    required this.videoType,
    required this.videoURLType,
    required this.videoId,
    this.videoThumbnailImage = '',
    this.isTrailer = true,
    this.isFromDashboard = false,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late PodPlayerController podPlayerController;
  bool isMute = false;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();

    if (widget.videoType == PostType.CHANNEL) {
      _initializeLiveStreamPlayer();
    } else {
      _initializeRegularPlayer();
    }
  }

  void _initializeLiveStreamPlayer() {
    final podPlayerConfig = PodPlayerConfig(
      autoPlay: widget.watchedTime.isEmpty,
      wakelockEnabled: true,
      isLooping: false,
      forcedVideoFocus: true,
    );

    final headers = <String, String>{
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': mDomainUrl,
      'Referer': mDomainUrl,
      'Connection': 'keep-alive',
    };

    podPlayerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        widget.videoURL,
        httpHeaders: headers,
      ),
      podPlayerConfig: podPlayerConfig,
    );

    _initializePlayerWithErrorHandling();
  }

  void _initializeRegularPlayer() {
    podPlayerController = PodPlayerController(
      playVideoFrom: widget.videoURL.getPlatformVideo(),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: widget.watchedTime.isEmpty,
        wakelockEnabled: true,
        isLooping: widget.isTrailer,
        forcedVideoFocus: true,
      ),
    );

    _initializePlayerWithErrorHandling();
  }

  Future<void> _initializePlayerWithErrorHandling() async {
    try {
      await podPlayerController.initialise();

      if (widget.isTrailer) {
        podPlayerController.mute();
        isMute = true;
      }

      if (widget.watchedTime.isNotEmpty && !widget.isTrailer && isFirstTime && widget.videoType != PostType.CHANNEL) {
        isFirstTime = false;
        podPlayerController.pause();
        resumeVideoDialog();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (widget.videoType == PostType.CHANNEL) {
        _tryAlternativeLiveStreamInit();
      } else {
        _showErrorMessage('Failed to load video. Please try again.');
      }
    }
  }

  Future<void> _tryAlternativeLiveStreamInit() async {
    try {
      podPlayerController.dispose();
      final minimalHeaders = <String, String>{
        'User-Agent': 'ExoPlayer/2.18.1',
        'Accept': 'application/vnd.apple.mpegurl,*/*',
      };

      final newController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(
          widget.videoURL,
          httpHeaders: minimalHeaders,
        ),
        podPlayerConfig: PodPlayerConfig(
          autoPlay: true,
          wakelockEnabled: true,
          isLooping: false,
          forcedVideoFocus: true,
        ),
      );

      setState(() {
        podPlayerController = newController;
      });

      await podPlayerController.initialise();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showErrorMessage(language!.liveStreamErrorMessage);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> saveWatchTime() async {
    if (widget.videoType == PostType.CHANNEL) return;
    try {
      await saveVideoContinueWatch(
        postId: widget.videoId.validate().toInt(),
        watchedTotalTime: podPlayerController.videoPlayerValue!.duration.inSeconds,
        watchedTime: podPlayerController.videoPlayerValue!.position.inSeconds,
        postType: widget.videoType,
      ).then((value) {
        LiveStream().emit(RefreshHome);
      });
    } catch (e) {
      log('Error saving watch time: $e');
    }
  }

  void resumeVideoDialog() {
    int watchedSeconds = int.parse(widget.watchedTime);
    showResumeVideoDialog(
      context: context,
      resume: () async {
        podPlayerController.videoSeekForward(Duration(seconds: watchedSeconds));
        podPlayerController.play();
      },
      starOver: () {
        podPlayerController.videoSeekBackward(Duration(seconds: 0));
        podPlayerController.play();
      },
    );
  }

  @override
  void dispose() {
    if (appStore.isLogging && !widget.isTrailer && widget.videoType != PostType.CHANNEL) {
      saveWatchTime();
    }
    podPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: context.scaffoldBackgroundColor,
            ),
            primaryColor: Colors.white,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Observer(builder: (context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: PodVideoPlayer(
                  alwaysShowProgressBar: false,
                  controller: podPlayerController,
                  frameAspectRatio: 16 / 9,
                  videoAspectRatio: 16 / 9,
                  videoThumbnail: widget.videoThumbnailImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.videoThumbnailImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  onVideoError: () {
                    return Container(
                      height: appStore.showPIP ? 110 : 200,
                      width: context.width(),
                      decoration: boxDecorationDefault(
                        color: context.scaffoldBackgroundColor,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 34, color: white),
                          10.height,
                          Text(
                            language!.videoNotFound,
                            style: boldTextStyle(size: 16, color: white),
                          ),
                        ],
                      ),
                    );
                  },
                  onLoading: (context) {
                    return LoaderWidget();
                  },
                  podProgressBarConfig: PodProgressBarConfig(
                    circleHandlerColor: colorPrimary,
                    backgroundColor: context.scaffoldBackgroundColor,
                    playingBarColor: colorPrimary,
                    bufferedBarColor: colorPrimary,
                    circleHandlerRadius: 6,
                    height: 2.6,
                    alwaysVisibleCircleHandler: false,
                    padding: EdgeInsets.only(bottom: 16, left: 8, right: 8),
                  ),
                  onToggleFullScreen: (isFullScreen) {
                    return Future(() {
                      if (isFullScreen)
                        setOrientationLandscape();
                      else
                        setOrientationPortrait();
                      return appStore.setToFullScreen(isFullScreen);
                    });
                  },
                ),
              );
            }),
          ),
        ),
        if (widget.videoType == PostType.CHANNEL)
          Positioned(
            right: 0,
            top: 24,
            child: LiveTagComponent(),
          ),
        if (widget.isTrailer && widget.videoType != PostType.CHANNEL && podPlayerController.isInitialised)
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: () {
                isMute = !isMute;
                isMute ? podPlayerController.mute() : podPlayerController.unMute();
                setState(() {});
              },
              icon: Icon(
                size: 18,
                isMute ? Icons.volume_off_outlined : Icons.volume_down_rounded,
              ),
            ),
          ),
      ],
    );
  }
}
