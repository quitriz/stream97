import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/view_video/video_player_widget.dart';
import 'package:streamit_flutter/components/view_video/webview_content_widget.dart';
import 'package:streamit_flutter/components/view_video/youtube_player_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

class VideoWidget extends StatelessWidget {
  final String videoURL;
  final String? watchedTime;
  final PostType videoType;
  final String? videoURLType;
  final int videoId;
  final String thumbnailImage;
  final VoidCallback? onTap;
  final bool isSlider;
  final bool isTrailer;

  VideoWidget({
    required this.videoURL,
    this.watchedTime,
    required this.videoType,
    this.videoURLType,
    required this.videoId,
    this.onTap,
    this.isSlider = false,
    required this.thumbnailImage,
    required this.isTrailer,
  });

  bool _isValidHttpUrl(String url) {
    final value = url.validate().trim();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  bool _isValidTrailerUrl() {
    final url = videoURL.validate().trim();
    final type = videoURLType.validate().toLowerCase();

    if (url.isEmpty) return false;

    if (type == VideoType.typeYoutube) {
      // Accept if we can extract a valid YouTube ID (supports bare 11-char IDs)
      return url.getYouTubeId().isNotEmpty;
    }

    if (type == VideoType.typeVimeo) {
      return url.getVimeoVideoId.validate().isNotEmpty;
    }

    if (type == VideoType.typeFile) {
      // Local file paths are acceptable
      return true;
    }

    // For generic URLs (including HLS files), require http/https scheme
    return _isValidHttpUrl(url);
  }

  bool _shouldShowThumbnail() {
    // Show thumbnail if URL/type missing OR if trailer URL is not valid/playable
    if (videoURL.validate().isEmpty || videoURLType.validate().isEmpty) return true;
    if (isTrailer && !_isValidTrailerUrl()) return true;
    return false;
  }


  Widget _buildErrorFallback(BuildContext context, Size cardSize) {
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  videoType == PostType.CHANNEL ? Icons.live_tv : Icons.play_circle_outline,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  language.videoUnavailableMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
      onTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = context.width();
    final Size cardSize = Size(width, appStore.hasInFullScreen ? context.height() : context.height() * 0.3);
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: boxDecorationDefault(
        color: context.cardColor,
        boxShadow: [],
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            context.scaffoldBackgroundColor.withValues(alpha: 0.3),
          ],
          stops: [0.3, 1.0],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          tileMode: TileMode.mirror,
        ),
      ),
      child: _shouldShowThumbnail()
          ? Stack(
              children: [
                CachedImageWidget(
                  url: thumbnailImage.validate(),
                  width: cardSize.width,
                  height: cardSize.height,
                  fit: BoxFit.cover,
                ).onTap(
                  () {
                    onTap?.call();
                  },
                ),
              ],
            )
          : _buildVideoPlayer(context, cardSize),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, Size cardSize) {
    if (videoType == PostType.CHANNEL) {
      return _buildLiveStreamPlayer(context, cardSize);
    }

    return _buildRegularVideoPlayer(context, cardSize);
  }

  Widget _buildLiveStreamPlayer(BuildContext context, Size cardSize) {
    final url = videoURL.validate();
    if (url.isEmpty || (!url.contains('.m3u8') && !url.contains('hls') && videoURLType.validate().toLowerCase() != VideoType.typeHLS) || !_isValidHttpUrl(url)) {
      log('Invalid live stream URL or type: $videoURL, Type: $videoURLType');
      return _buildErrorFallback(context, cardSize);
    }

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onTap?.call();
      },
      child: VideoPlayerWidget(
        videoURL: videoURL.validate(),
        watchedTime: '',
        videoType: videoType,
        videoURLType: videoURLType.validate(),
        videoId: videoId,
        videoThumbnailImage: thumbnailImage,
        isTrailer: false,
        isFromDashboard: isSlider,
      ),
    );
  }

  Widget _buildRegularVideoPlayer(BuildContext context, Size cardSize) {
    if (videoURLType.validate().toLowerCase() == VideoType.typeYoutube) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: YoutubePlayerWidget(
          videoURL: videoURL.validate(),
          watchedTime: watchedTime.validate(),
          videoType: videoType,
          videoURLType: videoURLType.validate(),
          videoId: videoId,
          videoThumbnailImage: thumbnailImage,
          isTrailer: isTrailer,
          isSlider: isSlider,
        ),
      );
    } else if (videoURLType.validate().toLowerCase() == VideoType.typeVimeo) {
      // Guard against missing/invalid Vimeo id
      if (videoURL.getVimeoVideoId.validate().isEmpty) {
        return Stack(
          children: [
            CachedImageWidget(
              url: thumbnailImage.validate(),
              width: cardSize.width,
              height: cardSize.height,
              fit: BoxFit.cover,
            ).onTap(() {
              onTap?.call();
            }),
          ],
        );
      }
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: WebViewContentWidget(
          uri: Uri.parse('https://player.vimeo.com/video/${videoURL.getVimeoVideoId}'),
          autoPlayVideo: isTrailer,
        ),
      );
    } else {
      // For non-YouTube/Vimeo types, if this is a trailer ensure we only play proper http/https URLs
      if (isTrailer && !_isValidHttpUrl(videoURL.validate())) {
        return Stack(
          children: [
            CachedImageWidget(
              url: thumbnailImage.validate(),
              width: cardSize.width,
              height: cardSize.height,
              fit: BoxFit.cover,
            ).onTap(() {
              onTap?.call();
            }),
          ],
        );
      }
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: VideoPlayerWidget(
          videoURL: videoURL.validate(),
          watchedTime: watchedTime.validate(),
          videoType: videoType,
          videoURLType: videoURLType.validate(),
          videoId: videoId,
          videoThumbnailImage: thumbnailImage,
          isTrailer: isTrailer,
          isFromDashboard: isSlider,
        ),
      );
    }
  }
}
