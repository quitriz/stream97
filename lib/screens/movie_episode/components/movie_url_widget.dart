import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class MovieURLWidget extends StatefulWidget {
  static String tag = '/MovieURLWidget';

  String? url;
  final String? title;
  final String? image;
  final String videoId;
  final String videoDuration;

  final String videoURLType;
  final String watchedTime;
  final VoidCallback? videoCompletedCallback;

  final PostType postType;

  MovieURLWidget(
    this.url, {
    this.title,
    this.image,
    required this.videoId,
    required this.videoDuration,
    this.videoCompletedCallback,
    required this.videoURLType,
    required this.watchedTime,
    required this.postType,
  });

  @override
  MovieURLWidgetState createState() => MovieURLWidgetState();
}

class MovieURLWidgetState extends State<MovieURLWidget> {
  bool isYoutubeUrl = true;
  int? lastWatchDuration;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  bool get isMovieFromGoogleDriveLink => widget.url.validate().startsWith("https://drive.google.com");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isYoutubeUrl || widget.url.validate().isLiveURL || widget.url.validate().isVideoPlayerFile
        ? VideoWidget(
            videoURL: widget.url.validate(),
            watchedTime: widget.watchedTime,
            videoType: widget.postType,
            videoURLType: widget.videoURLType.validate(),
            videoId: widget.videoId.toInt(),
            thumbnailImage: widget.image.validate(),
            isTrailer: false,
          )
        : isMovieFromGoogleDriveLink
            ? SizedBox(
                width: context.width(),
                height: appStore.hasInFullScreen ? context.height() : context.height() * 0.3,
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.dataFromString(movieEmbedCode, mimeType: "text/html")),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          if (appStore.hasInFullScreen) {
                            appStore.setToFullScreen(false);
                          } else {
                            appStore.setToFullScreen(true);
                          }
                        },
                        icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (appStore.hasInFullScreen) {
                          appStore.setToFullScreen(false);
                        } else {
                          appStore.setPIPOn(false);
                          finish(context);
                        }
                      },
                      icon: Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: context.width(),
                height: 200,
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(widget.url.validate())),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          if (appStore.hasInFullScreen) {
                            appStore.setToFullScreen(false);
                          } else {
                            appStore.setToFullScreen(true);
                          }
                        },
                        icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (appStore.hasInFullScreen) {
                          appStore.setToFullScreen(false);
                        } else {
                          appStore.setPIPOn(false);
                          finish(context);
                        }
                      },
                      icon: Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              );
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
        \$('iframe').attr('src','${widget.url.validate()}');
        \$('iframe').css('border','none');
        \$('iframe').attr('width','100%');
        \$('iframe').attr('height','100%');
        \$(document).ready(function(){
              \$(".ndfHFb-c4YZDc-Wrql6b").hide();
            });
        });
      </script>
    </html> ''';
}