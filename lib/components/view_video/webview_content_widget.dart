import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContentWidget extends StatefulWidget {
  final Uri uri;

  final bool autoPlayVideo;

  const WebViewContentWidget({
    required this.uri,
    this.autoPlayVideo = false,
  });

  @override
  State<WebViewContentWidget> createState() => _WebViewContentWidgetState();
}

class _WebViewContentWidgetState extends State<WebViewContentWidget> with AutomaticKeepAliveClientMixin {
  WebViewController? _webViewController;
  bool isFullscreen = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }

  void _loadContent() {
    _webViewController = WebViewController()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FullscreenChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'enterFullscreen') {
            _enterFullscreen();
          } else if (message.message == 'exitFullscreen') {
            _exitFullscreen();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _injectFullscreenDetection();
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  Future<void> _injectFullscreenDetection() async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.runJavaScript('''
        (function() {
          // Find all video elements and add fullscreen event listeners
          const videos = document.querySelectorAll('video');
          videos.forEach(video => {
            // Add fullscreen event listeners
            video.addEventListener('webkitbeginfullscreen', function() {
              window.FullscreenChannel.postMessage('enterFullscreen');
            });
            
            video.addEventListener('webkitendfullscreen', function() {
              window.FullscreenChannel.postMessage('exitFullscreen');
            });
          });
          
          // Listen for fullscreen changes using Fullscreen API
          document.addEventListener('fullscreenchange', function() {
            if (document.fullscreenElement) {
              window.FullscreenChannel.postMessage('enterFullscreen');
            } else {
              window.FullscreenChannel.postMessage('exitFullscreen');
            }
          });
          
          // For webkit browsers
          document.addEventListener('webkitfullscreenchange', function() {
            if (document.webkitFullscreenElement) {
              window.FullscreenChannel.postMessage('enterFullscreen');
            } else {
              window.FullscreenChannel.postMessage('exitFullscreen');
            }
          });
        })();
      ''');
    } catch (e) {
      debugPrint("Error injecting fullscreen detection script: $e");
    }
  }

  void _enterFullscreen() {
    if (isFullscreen) return;

    setState(() {
      isFullscreen = true;
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    if (!isFullscreen) return;

    setState(() {
      isFullscreen = false;
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: context.width(),
      height: isFullscreen ? context.height() : context.height() * 0.3,
      child: _webViewController != null ? WebViewWidget(controller: _webViewController!) : Loader(),
    );
  }
}