import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/network_utils.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart' as web_view;
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/resources/colors.dart' show appBackground, colorPrimary;

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  WebViewScreen({required this.url, required this.title});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  Completer<web_view.WebViewController> webCont = Completer<web_view.WebViewController>();

  //WebViewController _webViewController = WebViewController();
  late final WebViewController _webViewController;

  bool fetchingFile = true;
  bool? orderDone;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String newURL = '${widget.url}?HTTP_STREAMIT_WEBVIEW=true';
    if (appStore.isLogging) {
      newURL += '&auth_token=Bearer ${getStringAsync(TOKEN)}';
    }
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (msg) {},
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
          },
          onPageFinished: (url) {
            if (url.contains("membership-confirmation")) {
              // Update with actual success URL
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: appBackground,
                      title: Text(
                        "Payment Successful",
                        style: boldTextStyle(
                          size: 20,
                        ),
                      ),
                      content: Text(
                        "Your payment has been processed successfully.",
                        style: secondaryTextStyle(size: 16),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false); // Return success result
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorPrimary,
                              ),
                              child: Text(
                                "OK",
                                style: boldTextStyle(size: 20),
                              )),
                        ),
                      ],
                    );
                  });
            }
          },
          onProgress: (progress) {
            if (progress == 100) appStore.setLoading(false);
          },
          onWebResourceError: (error) {},
          onNavigationRequest: (request) async {
            return NavigationDecision.navigate; // Allow navigation
          },
        ),
      )
      ..loadRequest(
        Uri.parse(newURL),
        headers: await buildTokenHeader(isWebView: true),
      );
    setState(() {}); // Ensure UI updates
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _webViewController.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .cardColor,
        centerTitle: true,
        title: Text(widget.title.validate(), style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          web_view.WebViewWidget(
            controller: _webViewController,
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}