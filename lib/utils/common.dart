import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tab;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/models/movie_episode/comment_model.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/network/network_utils.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';
import '../models/live_tv/live_channel_detail_model.dart';
import 'app_widgets.dart';

Future<bool> get isIqonicProduct async => await getPackageName() == iqonicAppPackageName;

String get appNameTopic => app_name.toLowerCase().replaceAll(' ', '_');

SystemUiOverlayStyle defaultSystemUiOverlayStyle(BuildContext context, {Color? color, Brightness? statusBarIconBrightness}) {
  return SystemUiOverlayStyle(
      statusBarColor: color ?? context.scaffoldBackgroundColor,
      statusBarIconBrightness: statusBarIconBrightness ?? Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: context.scaffoldBackgroundColor);
}

String formatWatchedTime({required int totalSeconds, required int watchedSeconds}) {
  int remainingSeconds = totalSeconds - watchedSeconds;

  String text = Duration(seconds: remainingSeconds).toString().split('.').first;

  // Remove leading 0: if it's an hour format like 0:01:25
  if (text.startsWith('0:')) {
    text = text.substring(2);
  }

  return '$text left';
}

String formatRemainingTime(int totalMinutes, int watchedMinutes) {
  if (totalMinutes < 0 || watchedMinutes < 0 || watchedMinutes > totalMinutes) {
    return "Invalid input";
  }

  int remainingMinutes = totalMinutes - watchedMinutes;
  int hours = remainingMinutes ~/ 60;
  int minutes = remainingMinutes % 60;

  String formattedTime = "";

  if (hours > 0) {
    formattedTime += "$hours" + "h ";
  }

  if (minutes > 0) {
    formattedTime += "$minutes" + "m";
  }

  return formattedTime;
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String buildLikeCountText(int like) {
  if (like > 1) {
    return '$like ${language!.likes}';
  } else {
    return '$like ${language!.like}';
  }
}

String buildCommentCountText(int comment) {
  if (comment == 0) return language!.lblNoRatingsYet;
  if (comment > 1) {
    return '$comment ${language!.ratings}';
  } else {
    return '$comment  ${language!.lblRating}';
  }
}

Future<void> setUserData({required LoginResponse logRes}) async {
  appStore.setLogging(true);
  appStore.setUserId(logRes.userId.validate());
  appStore.setUserName(logRes.username.validate());
  appStore.setUserEmail(logRes.userEmail.validate());
  appStore.setFirstName(logRes.firstName.validate());
  appStore.setLastName(logRes.lastName.validate());
  appStore.setUserProfile(logRes.profileImage.validate().isEmpty ? userProfileImage() : logRes.profileImage.validate());

  if (logRes.plan != null) {
    appStore.setSubscriptionPlanStatus(logRes.plan!.status.validate());

    if (logRes.plan!.status == userPlanStatus) {
      appStore.setSubscriptionPlanId(logRes.plan!.subscriptionPlanId.validate());
      appStore.setSubscriptionPlanStartDate(logRes.plan!.startDate.validate());
      appStore.setSubscriptionPlanExpDate(logRes.plan!.expirationDate.validate());
      appStore.setSubscriptionPlanName(logRes.plan!.subscriptionPlanName.validate());
      appStore.setSubscriptionPlanAmount(logRes.plan!.billingAmount.validate());
      appStore.setSubscriptionTrialPlanStatus(logRes.plan!.trailStatus.validate());
      appStore.setSubscriptionTrialPlanEndDate(logRes.plan!.trialEnd.validate());
      if (appStore.isInAppPurChaseEnable) {
        appStore.setActiveSubscriptionIdentifier(isIOS ? logRes.plan!.playStorePlanIdentifier.validate() : logRes.plan!.playStorePlanIdentifier.validate());
        appStore.setActiveSubscriptionGoogleIdentifier(logRes.plan!.playStorePlanIdentifier.validate());
        appStore.setActiveSubscriptionAppleIdentifier(logRes.plan!.appStorePlanIdentifier.validate());
      }
    }
  }
}

Future<void> callNativeWebView(Map params) async {
  const platform = const MethodChannel('webviewChannel');

  if (isMobile) {
    await platform.invokeMethod('webview', params);
  }
}

Future<CommentModel> buildComment({int? parentId, required String content, required int? postId, num? rating,required String? postType}) async {
  if (content.isNotEmpty) {
/*    CommentModel comment = CommentModel();
    comment.postType = postType;
    comment.postId=postId;
    comment.userName= getStringAsync(USERNAME);
      comment.userEmail= getStringAsync(USER_EMAIL);
    comment.rating = rating;
    comment.commentData = content;*/
  var request = {
    'post_type': postId,
    'post_id': parentId ?? 0,
    'user_name': getIntAsync(USER_ID).toInt(),
    'user_email': getStringAsync(USERNAME),
    'rating': getStringAsync(USER_EMAIL),
    'cm_details': content,
  };

/*    comment.post = postId;
    comment.parent = parentId ?? 0;
    comment.author = getIntAsync(USER_ID).toInt();
    comment.authorName = getStringAsync(USERNAME);
    comment.date = DateTime.now().toString();
    comment.dateGmt = DateTime.now().toString();
    comment.commentData = content;
    comment.authorUrl = '';
    comment.link = '';
    comment.rating = rating;*/

    return await addComment(request).then((value) {
      toast(language!.commentAdded);
      return value;
    }).catchError((error) {
      toast(error.toString());
      return CommentModel();
    });
  } else {
    throw (language!.writeSomething);
  }
}

class TabIndicator extends Decoration {
  final BoxPainter painter = TabPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => painter;
}

class TabPainter extends BoxPainter {
  Paint? _paint;

  TabPainter() {
    _paint = Paint()..color = colorPrimary;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Size size = Size(configuration.size!.width, 3);
    Offset _offset = Offset(offset.dx, offset.dy + 40);
    final Rect rect = _offset & size;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        _paint!);
  }
}


Future<void> launchCustomTabURL({required String url}) async {
  String authURL = '${url}?HTTP_STREAMIT_WEBVIEW=true';
  if (appStore.isLogging) {
    authURL += '&auth_token=Bearer ${getStringAsync(TOKEN)}';
  }
  try {
    await custom_tab.launchUrl(
      Uri.parse(authURL),
      customTabsOptions: custom_tab.CustomTabsOptions(
        colorSchemes: custom_tab.CustomTabsColorSchemes.defaults(toolbarColor: colorPrimary),
        animations: custom_tab.CustomTabsSystemAnimations.slideIn(),
        urlBarHidingEnabled: true,
        shareState: custom_tab.CustomTabsShareState.on,
        browser: custom_tab.CustomTabsBrowserConfiguration(
          fallbackCustomTabs: [
            'org.mozilla.firefox',
            'com.microsoft.emmx',
          ],
          headers: await buildTokenHeader(isWebView: true),
        ),
      ),
      safariVCOptions: custom_tab.SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: custom_tab.SafariViewControllerDismissButtonStyle.close,
        entersReaderIfAvailable: false,
        preferredControlTintColor: Colors.white,
        preferredBarTintColor: colorPrimary,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

Future<void> addOrRemoveFromLocalStorage(DownloadData data, {bool isDelete = false}) async {
  List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];

  if (list.isNotEmpty) {
    if (isDelete) {
      for (var i in list) {
        if (i.id == data.id) {
          appStore.downloadedItemList.removeWhere((element) => element.id == data.id);

          final file = File(data.filePath.validate());
          if (await file.exists()) {
            await file.delete().then((value) {
              toast(language!.movieDeletedSuccessfullyFromDownloads);
              log('File Deleted  ===============> ${value.toString()}');
            }).catchError((e) {
              log('Error ===============> ${e.toString()}');
            });
          }
          break;
        }
      }
    } else {
      appStore.downloadedItemList.add(data);
    }
  } else {
    appStore.downloadedItemList.add(data);
  }

  log("Downloaded Item : ${list.map((e) => e.id)}");
  await setValue(DOWNLOADED_DATA, jsonEncode(appStore.downloadedItemList));
  log("Decoded downloaded items : ${getStringAsync(DOWNLOADED_DATA)}");
}

 Future<void> shareMovieOrEpisode(String videUrl) async{
 await SharePlus.instance.share(ShareParams(text: videUrl));
}

Future<String> getQualitiesAsync({required String videoId, required String embedContent}) async {
  try {
    final videoUrl = 'https://player.vimeo.com/video/$videoId/config';
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['request']['files']['progressive'];
      if (jsonData is List && !jsonData.isEmpty) {
        final videoList = SplayTreeMap.fromIterable(jsonData, key: (item) => "${item['quality']}", value: (item) => item['url']);
        final maxQuality = videoList.keys.map((e) => int.parse(e)).reduce(max);
        return videoList[maxQuality.toString()] as String;
      }
    }
    return getVideoLink(embedContent.validate());
  } catch (error) {
    log('=====> REQUEST ERROR: $error <=====');
    return getVideoLink(embedContent.validate());
  }
}

Future<void> appLaunchUrl(String url, {bool forceWebView = false}) async {
  await url_launcher.launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
    return Future.value(false);
  });
}

String getVideoLink(String htmlData) {
  var document = parse(htmlData);
  dom.Element? link = document.querySelector('iframe');
  String? iframeLink = link != null ? link.attributes['src'].validate() : '';
  return iframeLink.validate();
}

InputDecoration inputDecorationFilled(BuildContext context, {String? label, EdgeInsetsGeometry? contentPadding, required Color fillColor, Widget? prefix}) {
  return InputDecoration(
    fillColor: fillColor,
    filled: true,
    contentPadding: contentPadding ?? EdgeInsets.all(16),
    labelText: label,
    labelStyle: secondaryTextStyle(color: Colors.white),
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    disabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    border: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
    prefix: prefix,
  );
}

Future<bool> checkPermission() async {
  if (isAndroid || isIOS) {
    if (await isAndroid12Above()) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      bool isGranted = false;
      statuses.forEach((key, value) {
        isGranted = value.isGranted;
      });

      return isGranted;
    }
  } else {
    return false;
  }
}

void showResumeVideoDialog({required BuildContext context, required VoidCallback starOver, required VoidCallback resume}) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        surfaceTintColor: context.cardColor,
        backgroundColor: context.cardColor,
        title: Text(language!.resumeVideo, style: boldTextStyle()),
        content: Text(language!.doYouWishTo, style: primaryTextStyle()),
        actions: [
          TextButton(
            onPressed: () {
              finish(context);
              starOver.call();
            },
            child: Text(language!.startOver, style: primaryTextStyle()),
          ),
          TextButton(
            onPressed: () async {
              finish(context);
              resume.call();
            },
            child: Text(language!.resume, style: primaryTextStyle()),
          )
        ],
      );
    },
  );
}

Widget noDataImage() {
  return Image.asset(no_data_gif, height: 160, width: 160, fit: BoxFit.cover).cornerRadiusWithClipRRect(80);
}

double getWidth(BuildContext context) {
  double width = 140;

  if (context.width() < 400) {
    width = context.width() / 2 - 20;
  } else {
    width = context.width() / 3 - 16;
  }

  return width;
}

extension intExt on int? {
  Color getRatingBarColor() {
    if (this == 1 || this == 2) {
      return Color(0xFFE80000);
    } else if (this == 3) {
      return Color(0xFFff6200);
    } else if (this == 4 || this == 5) {
      return Color(0xFF73CB92);
    } else {
      return Color(0xFFE80000);
    }
  }
}

String formatDate(String date) {
  DateTime input = DateFormat('yyyy-MM-DDTHH:mm:ss').parse(date, true);

  return DateFormat.yMMMMd().format(input).toString();
}

InputDecoration inputDecoration(
  BuildContext context, {
  String? hint,
  String? label,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  Widget? prefix,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    contentPadding: contentPadding,
    labelText: label,
    hintText: hint,
    hintStyle: hintStyle ?? secondaryTextStyle(),
    labelStyle: labelStyle ?? secondaryTextStyle(),
    prefix: prefix,
    prefixIcon: prefixIcon,
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColorThird)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    border: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
    suffixIcon: suffixIcon,
  );
}

Widget buildUnavailable({required BuildContext context}) {
  return ElevatedButton(
    onPressed: () async {
      final state = await FlPiP().isAvailable;
      if (!state) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PiP unavailable')));
      }
    },
    child: const Text('PiP unavailable'),
  );
}

String convertToAgo(String dateTime) {
  if (dateTime.isNotEmpty) {
    DateTime? input;

    if (dateTime.contains('T')) {
      input = DateFormat(DATE_FORMAT_2).parse(dateTime, false);
    } else if (dateTime.contains('-') && dateTime.indexOf('-') == 2) {
      input = DateFormat(DATE_FORMAT_3).parse(dateTime, false);
    } else {
      input = DateFormat(DATE_FORMAT_1).parse(dateTime, false);
    }

    return streamitFormatTime(input.millisecondsSinceEpoch);
  } else {
    return '';
  }
}

String streamitFormatTime(int timestamp) {
  int difference = DateTime.now().millisecondsSinceEpoch - timestamp;
  String result;

  if (difference < 60000) {
    result = countSeconds(difference);
  } else if (difference < 3600000) {
    result = countMinutes(difference);
  } else if (difference < 86400000) {
    result = countHours(difference);
  } else if (difference < 604800000) {
    result = countDays(difference);
  } else if (difference / 1000 < 2419200) {
    result = countWeeks(difference);
  } else if (difference / 1000 < 31536000) {
    result = countMonths(difference);
  } else
    result = countYears(difference);

  return result != language!.justNow.capitalizeFirstLetter() ? result + ' ${language!.ago.toLowerCase()}' : result;
}

String getPostContent(String? postContent) {
  String content = '';

  content = postContent
      .validate()
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('[embed]', '<embed>')
      .replaceAll('[/embed]', '</embed>')
      .replaceAll('[caption]', '<caption>')
      .replaceAll('[/caption]', '</caption>')
      .replaceAll('[blockquote]', '<blockquote>')
      .replaceAll('[/blockquote]', '</blockquote>')
      .replaceAll('\t', '')
      .replaceAll('\n', '');

  return content;
}

String formatDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
}

extension DurationExtensions on Duration {
  String toFormattedString() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isNearZero => inMilliseconds < 100;

  bool isNearTo(Duration other, {Duration threshold = const Duration(seconds: 1)}) {
    return (inMilliseconds - other.inMilliseconds).abs() <= threshold.inMilliseconds;
  }
}

extension AdUnitExtensions on AdUnit {
  bool get isVideoAd => type?.toLowerCase() == 'video' || type?.toLowerCase() == 'vast';

  bool get isHtmlAd => type?.toLowerCase() == 'html';

  bool get isOverlayAd => isHtmlAd && overlay == true;

  bool get isCompanionAd => isHtmlAd && overlay != true && adFormat?.toLowerCase() == 'companion';

  bool get canBeSkipped => skipEnabled.validate();

  Duration get skipDurationAsDuration => Duration(seconds: skipDuration ?? 5);

  int get skipDurationInSeconds => skipDurationAsDuration.inSeconds;

  Duration get adDuration => Duration(seconds: duration ?? 5);
}