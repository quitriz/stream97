import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/episode_detail_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart' show MembershipPlansScreen;
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import '../main.dart';
import '../models/movie_episode/common_data_list_model.dart';
import '../models/movie_episode/movie_detail_response.dart';
import '../network/rest_apis.dart';
import '../screens/movie_episode/screens/movie_detail_screen.dart';
import 'constants.dart';

class PushNotificationService {
  Future<void> initFirebaseMessaging() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('-------------Init Firebase----------------');
      registerNotificationListeners();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      await FirebaseMessaging.instance.subscribeToTopic(appNameTopic).then((value) {
        log("${FirebaseMsgConst.topicSubscribed}${appNameTopic}");
      });
    }
  }

  Future<void> registerFCMAndTopics() async {
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        Future.delayed(const Duration(seconds: 3), () async {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        });
      }
      log("${FirebaseMsgConst.apnsNotificationTokenKey}\n$apnsToken");
    }
    FirebaseMessaging.instance.getToken().then((token) {
      log('----------Token-------------');
      log("${FirebaseMsgConst.fcmNotificationTokenKey}\n$token");
      setValue(FIREBASE_TOKEN, token);
      subScribeToTopic();
    });
  }

  Future<void> subScribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic("${FirebaseMsgConst.userWithUnderscoreKey}${appStore.userId}").then((value) {
      log("${FirebaseMsgConst.topicSubscribed}${FirebaseMsgConst.userWithUnderscoreKey}${appStore.userId}");
    });
  }

  Future<void> unsubscribeFirebaseTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('${FirebaseMsgConst.userWithUnderscoreKey}${appStore.userId}').whenComplete(() {
      log("${FirebaseMsgConst.topicUnSubscribed}${FirebaseMsgConst.userWithUnderscoreKey}${appStore.userId}");
    });
  }

  Future<void> handleNotificationClick(RemoteMessage message, {bool isForeGround = false}) async {
    printLogsNotificationData(message);
    if (isForeGround) {
      showNotification(currentTimeStamp(), message.notification!.title.validate(), message.notification!.body.validate(), message);
    } else {
      try {
        if (message.data.containsKey(FirebaseMsgConst.notificationType) && message.data[FirebaseMsgConst.notificationType] != "") {
          final additionalData = message.data;
          additionalData.entries.forEach((element) {});

          if (additionalData.containsValue(FirebaseMsgConst.subscriptionPlanAdded)) {
            if (appStore.isMembershipEnabled) navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => MembershipPlansScreen()));
          } else if (additionalData.containsValue(FirebaseMsgConst.contentType)) {
            if (additionalData.containsKey(FirebaseMsgConst.idKey)) {
              String? postId = additionalData[FirebaseMsgConst.idKey];
              String? postType = additionalData[FirebaseMsgConst.postTypeKey];

              Future<MovieDetailResponse>? future;

              if (postType == FirebaseMsgConst.movieKey) {
                future = movieDetail(postId.toInt().validate());
              } else if (postType == FirebaseMsgConst.tvShowKey) {
                future = tvShowDetail(postId.toInt().validate());
              } else if (postType == FirebaseMsgConst.episodeKey) {
                Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
                    builder: (context) => EpisodeDetailScreen(
                          episode: MovieData(id: postId.toInt()),
                        )));
              } else if (postType == FirebaseMsgConst.videoKey) {
                future = getVideosDetail(postId.toInt().validate());
              }

              if (postId.validate().isNotEmpty && future != null) {
                await future.then((value) {
                  if (value.data != null) {
                    CommonDataListModel movie = CommonDataListModel(
                      image: value.data!.image,
                      title: value.data!.title,
                      id: value.data!.id,
                      postType: value.data!.postType!,
                    );

                    appStore.setTrailerVideoPlayer(true);
                    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => MovieDetailScreen(movieData: movie)));
                  }
                });
              }
            }
          } else {}
        }
      } catch (e) {
        log("${FirebaseMsgConst.onClickListener} $e");
      }
    }
  }

  Future<void> registerNotificationListeners() async {
    FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        handleNotificationClick(message, isForeGround: true);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageListen} $e");
      });

      // replacement for onResume: When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleNotificationClick(message);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageOpened} $e");
      });

      // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          handleNotificationClick(message);
        }
      }, onError: (e) {
        log("${FirebaseMsgConst.onGetInitialMessage} $e");
      });
    }).onError((error, stackTrace) {
      log("${FirebaseMsgConst.onGetInitialMessage} $error");
    });
  }

  void showNotification(int id, String title, String message, RemoteMessage remoteMessage) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //code for background notification channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      FirebaseMsgConst.notificationChannelIdKey,
      FirebaseMsgConst.notificationChannelNameKey,
      importance: Importance.high,
      enableLights: true,
      playSound: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_ic_notification');

    var iOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var macOS = iOS;

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {
      handleNotificationClick(remoteMessage);
    });

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      FirebaseMsgConst.notificationChannelIdKey,
      FirebaseMsgConst.notificationChannelNameKey,
      importance: Importance.high,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      playSound: true,
      priority: Priority.high,
      color: colorPrimary,
      colorized: true,
      icon: '@drawable/ic_stat_ic_notification',
    );

    var darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentBadge: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(id, title, message, platformChannelSpecifics);
  }

  void printLogsNotificationData(RemoteMessage message) {
    log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
    log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
    log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
    log('${FirebaseMsgConst.messageDataCollapseKey} : ${message.collapseKey}');
    log('${FirebaseMsgConst.messageDataMessageIdKey} : ${message.messageId}');
  }
}