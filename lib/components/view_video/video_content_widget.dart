import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/components/view_video/webview_content_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/movie_url_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import '../../main.dart';

class VideoContentWidget extends StatelessWidget {
  final String choice;
  final String urlLink;
  final String? embedContent;
  final String fileLink;
  final String image;
  final String title;
  final String videoId;
  final bool isUserResumeVideo;
  final String watchedTime;

  final VoidCallback? onMovieCompleted;

  final PostType postType;

  VideoContentWidget({
    required this.choice,
    required this.urlLink,
    this.embedContent,
    this.fileLink = '',
    this.image = '',
    required this.title,
    required this.videoId,
    this.isUserResumeVideo = false,
    this.watchedTime = '',
    this.onMovieCompleted,
    required this.postType,
  });

  @override
  Widget build(BuildContext context) {
    if (choice.validate() == movieChoiceURL ||
        choice.validate() == videoChoiceURL ||
        choice.validate() == episodeChoiceURL ||
        choice.validate() == movieChoiceLiveStream ||
        choice == episodeChoiceLiveStream ||
        choice == episodeChoiceLiveStream ||
        choice == videoChoiceLiveStream) {
      return MovieURLWidget(
        urlLink.validate(),
        title: title.validate(),
        image: image.validate(),
        watchedTime: watchedTime,
        videoId: videoId,
        videoDuration: watchedTime,
        videoURLType: urlLink.getURLType(),
        postType: postType,
        videoCompletedCallback: () {
          onMovieCompleted?.call();
        },
      );
    } else if (choice.validate() == movieChoiceEmbed ||
        choice.validate() == videoChoiceEmbed ||
        choice.validate() == episodeChoiceEmbed) {
      String src = getVideoLink(embedContent.validate());
      if (src.isVimeoVideLink) {
        return FutureBuilder<String>(
          future: getQualitiesAsync(
              videoId: src.getVimeoVideoId.validate(),
              embedContent: embedContent.validate()),
          builder: (ctx, snap) {
            if (snap.hasData) {
              return VideoWidget(
                videoURL: snap.data.validate(),
                watchedTime: watchedTime,
                videoType: PostType.MOVIE,
                videoURLType: fileLink.getURLType(),
                videoId: videoId.validate().toInt(),
                thumbnailImage: image.validate(),
                isTrailer: false,
              );
            } else
              return CachedImageWidget(
                url: image.validate(),
                width: context.width(),
                height: context.height(),
                fit: BoxFit.cover,
              );
          },
        );
      } else if (src.isYoutubeUrl || src.isVideoPlayerFile) {
        return VideoWidget(
          videoURL: src,
          watchedTime: watchedTime,
          videoType: PostType.MOVIE,
          videoURLType: src.getURLType(),
          videoId: videoId.validate().toInt(),
          thumbnailImage: image.validate(),
          isTrailer: false,
        );
      } else {
        return WebViewContentWidget(
          uri: Uri.dataFromString(movieEmbedCode, mimeType: "text/html"),
          autoPlayVideo: true,
        );
      }
    } else if (choice.validate() == movieChoiceFile ||
        choice.validate() == videoChoiceFile ||
        choice.validate() == episodeChoiceFile) {
      return VideoWidget(
        videoURL: fileLink,
        watchedTime: watchedTime,
        videoType: PostType.MOVIE,
        videoURLType: fileLink.getURLType(),
        videoId: videoId.validate().toInt(),
        thumbnailImage: image.validate(),
        isTrailer: false,
      );
    } else {
      return Container(
        width: context.width(),
        height: appStore.hasInFullScreen
            ? context.height() - context.statusBarHeight
            : context.height() * 0.3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImageWidget(
              url: image.validate(),
              fit: BoxFit.cover,
              height: appStore.hasInFullScreen
                  ? context.height() - context.statusBarHeight
                  : context.height() * 0.3,
            ),
            Container(
              width: context.width(),
              height: appStore.hasInFullScreen
                  ? context.height() - context.statusBarHeight
                  : context.height() * 0.3,
              color: Colors.black.withValues(alpha: 0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.white),
                  16.height,
                  Text(
                    language!.videoUnavailable,
                    style: boldTextStyle(size: 20, color: Colors.white),
                  ),
                  8.height,
                  Text(
                    language!.privacyLinkCheckMessage,
                    style: secondaryTextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(horizontal: 32),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  String get movieEmbedCode => '''<html>
      <head>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
      </head>
      <body style="background-color: #000000;">
        <iframe></iframe>
      </body>
      <script>
        \$(function(){
        \$('iframe').attr('src','${embedContent.validate().urlFromIframe}');
        \$('iframe').css('border','none');
        \$('iframe').attr('width','100%');
        \$('iframe').attr('height','100%');
        });
      </script>
    </html> ''';
}
