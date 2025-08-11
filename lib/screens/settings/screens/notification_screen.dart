import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/notification_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notificationList = [];
  late Future<List<NotificationModel>> future;
  String filterType = FirebaseMsgConst.notificationTypeUnread;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    init();
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  init() {
    mIsLastPage = false;
    mPage = 1;
    future = getList();
  }

  readNotification(String id) {
    readNotificationAdd(id).then((value) {
      log("Notification read successfully");
      init();
      setState(() {});
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<List<NotificationModel>> getList() async {
    // Prevent further API calls if last page is reached
    log("filter type: $filterType");
    if (mIsLastPage) {
      print("No more notifications to load.");
      return notificationList;
    }

    appStore.setLoading(true);
    print("Fetching page: $mPage");

    try {
      List<NotificationModel> value = await getNotifications(page: mPage, type: filterType);

      if (mPage == 1) notificationList.clear(); // Clear list if first page

      // If fetched items are less than `postPerPage`, it's the last page
      if (value.length < postPerPage) {
        mIsLastPage = true;
        print("Reached last page.");
      }

      notificationList.addAll(value);

      setState(() {});
    } catch (e) {
      isError = true;
      print("Error: $e");
      toast(e.toString(), print: true);
    } finally {
      appStore.setLoading(false);
    }

    return notificationList;
  }

  Future<void> clear() async {
    appStore.setLoading(true);
    await clearNotification().then((value) {
      notificationList.clear();

      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language!.notifications,
        elevation: 0,
        color: Theme.of(context).cardColor,
        textColor: Colors.white,
        textSize: 22,
        /*   actions: [
          IconButton(
            onPressed: () async {
              await showConfirmDialogCustom(
                context,
                primaryColor: colorPrimary,
                cancelable: false,
                dialogType: DialogType.DELETE,
                positiveText: language!.clear,
                title: language!.clearNotificationConfirmation,
                onCancel: (value) {
                  finish(context);
                },
                onAccept: (_) async {
                  finish(context);
                  clear();
                },
              );
            },
            icon: Icon(Icons.delete_outline, color: context.primaryColor),
          )
        ],*/
      ),
      body: DefaultTabController(
        length: 2,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: search_edittext_color, borderRadius: BorderRadius.circular(25.0)),
                  child: TabBar(
                      dividerColor: Colors.black,
                      indicator: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(25.0)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: boldTextStyle(color: Colors.white),
                      unselectedLabelStyle: primaryTextStyle(color: Colors.white),
                      tabs: [
                        Tab(text: language!.unRead),
                        Tab(text: language!.read),
                      ],
                      onTap: (value) {
                        if (value == 0) {
                          filterType = FirebaseMsgConst.notificationTypeUnread;
                        } else {
                          filterType = FirebaseMsgConst.notificationTypeRead;
                        }
                        init();
                        setState(() {});
                      }),
                ),
                FutureBuilder<List<NotificationModel>>(
                  future: future,
                  builder: (ctx, snap) {
                    if (snap.hasError) {
                      return NoDataWidget(
                        imageWidget: noDataImage(),
                        title: language!.somethingWentWrong,
                      ).center();
                    }

                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty) {
                        return NoDataWidget(
                          imageWidget: noDataImage(),
                          title: language!.noNotificationsFound,
                        ).center();
                      } else {
                        return AnimatedListView(
                          shrinkWrap: true,
                          slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 50),
                          itemCount: notificationList.length,
                          itemBuilder: (context, index) {
                            NotificationModel notification = notificationList[index];

                            return ColoredBox(
                              color: context.scaffoldBackgroundColor,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  (notification.action == "pmp_new_plan")
                                        ? Container(
                                            height: 50,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                color: context.scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(defaultRadius)),
                                            child: CachedImageWidget(
                                                url: ic_notification,
                                                width: 42,
                                                height: 42,
                                                color: context.primaryColor),
                                          ).cornerRadiusWithClipRRect(defaultRadius)
                                        : CachedImageWidget(
                                            url: notification.imageUrl.validate(),
                                            height: 80,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(defaultRadius),
                                  20.width,
                                  Column(
                                    children: [
                                      Text(
                                        parseHtmlString(notification.message.validate()),
                                        style: primaryTextStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(notification.metaMessage.validate(), style: secondaryTextStyle()),
                                    ],
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  ).expand(),
                                ],
                              ).paddingSymmetric(vertical: 8, horizontal: 16),
                            ).onTap(() async {
                              await readNotification(notification.notificationId.toString());

                              if (notification.postType == FirebaseMsgConst.movieKey) {
                                MovieDetailScreen(movieData: CommonDataListModel(id: notification.id.isNotEmpty ? int.parse(notification.id.toString()) : 0, postType: PostType.MOVIE))
                                    .launch(context);
                              }
                            });
                          },
                          onNextPage: () {
                            if (!mIsLastPage) {
                              mPage++;
                              future = getList();
                            }
                          },
                        );
                      }
                    }
                    return Offstage();
                  },
                ).expand()
              ],
            ),
            Observer(
              builder: (_) {
                if (mPage == 1) {
                  return LoaderWidget().center().visible(appStore.isLoading);
                } else {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
