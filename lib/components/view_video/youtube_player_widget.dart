import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../utils/common.dart';
import '../../utils/constants.dart' hide PlayerState;
import '../../utils/resources/colors.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final int videoId;
  final String videoURL;
  final String videoThumbnailImage;
  final String watchedTime;
  final PostType videoType;
  final String videoURLType;
  final bool isTrailer;
  final isSlider;

  final VoidCallback? onTap;

  YoutubePlayerWidget({
    Key? key,
    required this.videoURL,
    required this.watchedTime,
    required this.videoType,
    required this.videoURLType,
    required this.videoId,
    this.videoThumbnailImage = '',
    this.isTrailer = true,
    this.isSlider = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  YoutubePlayerController? youtubePlayerController;
  bool isPlayerReady = false;
  bool isMute = false;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();

    String videoId = widget.videoURL.getYouTubeId();
    if (videoId.isNotEmpty) {
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.watchedTime.isEmpty,
          hideThumbnail: !widget.isTrailer,
          disableDragSeek: widget.isTrailer,
          loop: widget.isTrailer,
          forceHD: false,
          enableCaption: true,
          mute: widget.isTrailer,
          hideControls: widget.isTrailer,
        ),
      );
      youtubePlayerController!.addListener(() {
        if (isMute) {
          youtubePlayerController!.mute();
        }
      });

      initController();
    }
  }

  void initController() {
    if (youtubePlayerController != null) {
      if (widget.isTrailer) {
        youtubePlayerController?.mute();
        isMute = true;
      }

      if (widget.watchedTime.isNotEmpty && !widget.isTrailer && isFirstTime) {
        isFirstTime = false;
        afterBuildCreated(() => resumeVideoDialog());
      }
    }
  }

  void resumeVideoDialog() {
    youtubePlayerController?.pause();
    int watchedSeconds = int.parse(widget.watchedTime);

    showResumeVideoDialog(
      context: context,
      resume: () async {
        youtubePlayerController?.seekTo(Duration(seconds: watchedSeconds));
        youtubePlayerController?.play();
      },
      starOver: () {
        youtubePlayerController?.seekTo(Duration(seconds: 0));
        youtubePlayerController?.play();
      },
    );
  }

  Future<void> saveWatchTime() async {
    if (youtubePlayerController != null) {
      await saveVideoContinueWatch(
        postId: widget.videoId.validate().toInt(),
        watchedTotalTime: youtubePlayerController!.metadata.duration.inSeconds,
        watchedTime: youtubePlayerController!.value.position.inSeconds,
        postType: widget.videoType,
      ).then((value) {
        LiveStream().emit(RefreshHome);
      }).catchError(onError);
    }
  }

  void toggleMute() {
    isMute = !isMute;
    isMute ? youtubePlayerController?.mute() : youtubePlayerController?.unMute();
    setState(() {});
  }

  @override
  void dispose() {
    if (youtubePlayerController != null && youtubePlayerController!.value.isPlaying && youtubePlayerController!.value.playerState != PlayerState.ended && !widget.isTrailer) {
      saveWatchTime();
    }
    youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (youtubePlayerController != null)
          YoutubePlayerBuilder(
            key: widget.key,
            onEnterFullScreen: () {
              appStore.setToFullScreen(true);
            },
            onExitFullScreen: () {
              appStore.setToFullScreen(false);
            },
            player: YoutubePlayer(
              controller: youtubePlayerController!,
              liveUIColor: colorPrimary,
              progressColors: ProgressBarColors(
                playedColor: colorPrimary,
                bufferedColor: colorPrimary.withValues(alpha: 0.2),
                backgroundColor: colorPrimary.withValues(alpha: 0.2),
                handleColor: colorPrimary,
              ),
              progressIndicatorColor: colorPrimary,
              onReady: () {
                isPlayerReady = true;
              },
              onEnded: (data) {
                youtubePlayerController?.pause();
                if (widget.isTrailer) {
                  youtubePlayerController?.reload();
                  youtubePlayerController?.mute();
                }
              },
            ),
            builder: (context, player) {
              return player;
            },
          ),
        if (widget.isTrailer && youtubePlayerController != null && !youtubePlayerController!.value.isControlsVisible
            // &&
            // !widget.isSlider
            )
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: toggleMute,
              icon: Icon(
                size: 18,
                isMute ? Icons.volume_off_outlined : Icons.volume_down_rounded,
              ),
            ),
          )
      ],
    );
  }
}