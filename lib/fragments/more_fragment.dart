import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/screens/downloads/local_media_player_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_account_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/edit_profile_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/manage_devices_screen.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/playlist/screens/playlist_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/notification_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/settings_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';
import 'package:streamit_flutter/screens/home/view_all_continue_watchings_screen.dart';

class MoreFragment extends StatefulWidget {
  static String tag = '/MoreFragment';

  @override
  MoreFragmentState createState() => MoreFragmentState();
}

class MoreFragmentState extends State<MoreFragment> {
  String userName = "";
  String userEmail = "";
  bool isLoaderShow = true;
  MembershipModel? membership;

  int notification = 0;
  int mPage = 1;
  bool mIsLastPage = false;

  List<CommonDataListModel> continueWatch = [];

  List<CommonDataListModel> watchList = [];

  bool hasMembership = false;

  @override
  void initState() {
    super.initState();
    if (appStore.isLogging) getNotificationCount();
    getUserData();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void getUserData() async {
    appStore.setLoading(true);
    userName = '${getStringAsync(NAME)} ${getStringAsync(LAST_NAME)}';
    userEmail = getStringAsync(USER_EMAIL);
    getMemberShip();
    getContinueList();

    setState(() {});
    appStore.setLoading(false);
  }

  Future<void> getMemberShip() async {
    await getMembershipLevelForUser(userId: getIntAsync(USER_ID)).then((value) {
      if (value != null) {
        if (value != false) {
          hasMembership = true;
        } else {
          hasMembership = false;
        }

        appStore.setLoading(false);
      } else {
        hasMembership = false;
        appStore.setLoading(false);
      }

      setState(() {});
    });
  }

  Future<void> getContinueList() async {
    await getVideoContinueWatch(
      continueWatchList: continueWatch,
      page: 1,
      lastPageCallback: (p0) {},
    ).then((v) {
      setState(() {});
    });
  }

  Future<List<CommonDataListModel>> getList() async {
    getWatchList(page: mPage).then((value) {
      mIsLastPage = value.length != postPerPage;
      if (mPage == 1) watchList.clear();

      watchList.addAll(value);

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      setState(() {});
      toast(e.toString());
      appStore.setLoading(false);
    });

    return watchList.validate();
  }

  Future<void> getNotificationCount() async {
    await notificationCount().then((data) {
      notification = data.totalNotificationCount.validate();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(language!.profile, style: primaryTextStyle(size: ts_large.toInt(), color: textColorPrimary)),
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: defaultSystemUiOverlayStyle(context, color: Colors.black),
            actions: [
              IconButton(
                onPressed: () {
                  SettingsScreen().launch(context);
                },
                icon: Image.asset(ic_settings, color: context.iconColor, height: 20, width: 20, fit: BoxFit.cover),
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (appStore.isLogging) getNotificationCount();
              getUserData();
              return await 2.seconds.delay;
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Observer(
                        builder: (_) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: boxDecorationDefault(color: context.cardColor, boxShadow: []),
                          padding: EdgeInsets.only(
                            top: spacing_standard_new,
                            bottom: spacing_standard_new,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CachedImageWidget(
                                url: appStore.userProfileImage.validate(),
                                height: 50,
                                width: 50,
                                circle: true,
                                fit: BoxFit.cover,
                              ).paddingSymmetric(horizontal: 8),
                              8.width.visible(appStore.userProfileImage!.isNotEmpty),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${appStore.userFirstName} ${appStore.userLastName}', style: boldTextStyle(size: 18)),
                                  Text(userEmail, style: secondaryTextStyle(color: Colors.grey.shade500)),
                                ],
                              ).expand(),
                              IconButton(
                                onPressed: () {
                                  EditProfileScreen().launch(context);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: context.iconColor,
                                ),
                                padding: EdgeInsets.zero,
                              )
                            ],
                          ),
                        ).visible(appStore.isLogging),
                      ),
                      if (appStore.isLogging && appStore.isMembershipEnabled)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: [],
                          ),
                          child: Observer(
                            builder: (context) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      MyAccountScreen().launch(context);
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appStore.subscriptionPlanName.validate().isNotEmpty ? appStore.subscriptionPlanName.validate() : language!.free,
                                          style: primaryTextStyle(color: white, size: 20),
                                        ),
                                        if (appStore.subscriptionPlanExpDate.validate().toInt() != 0)
                                          Text(
                                            language!.validTill + DateTime.fromMillisecondsSinceEpoch(appStore.subscriptionPlanExpDate.validate().toInt() * 1000).toString().getFormattedDate()!,
                                            style: secondaryTextStyle(),
                                          ).paddingOnly(top: 4),
                                      ],
                                    ),
                                  ).expand(),
                                  16.width,
                                  Text(appStore.subscriptionPlanId.isNotEmpty ? language!.upgradePlan : language!.subscribeNow, style: boldTextStyle(color: colorPrimary, size: 14)).onTap(() {
                                    MembershipPlansScreen(
                                      selectedPlanId: appStore.subscriptionPlanId,
                                    ).launch(context).then((v) {
                                      if (v ?? false) getMemberShip();
                                    });
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                      if (appStore.isLogging && continueWatch.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headingWidViewAll(
                              context,
                              language!.continueWatching,
                              showViewMore: continueWatch.validate().length > 4,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              callback: () async {
                                ViewAllContinueWatchingScreen().launch(context);
                              },
                            ),
                            ItemHorizontalList(
                              continueWatch.validate(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              isContinueWatch: true,
                              isLandscape: true,
                              refreshContinueWatchList: () async {
                                await getContinueList();
                              },
                            ),
                          ],
                        ),
                      if (appStore.isLogging && appStore.downloadedItemList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headingWidViewAll(
                              context,
                              language!.downloads,
                              showViewMore: appStore.downloadedItemList.length > 3,
                              callback: () async {},
                            ),
                            HorizontalList(
                              spacing: 12,
                              runSpacing: 12,
                              itemCount: appStore.downloadedItemList.validate().length,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                DownloadData data = appStore.downloadedItemList[index];
                                if (data.userId == getIntAsync(USER_ID) && !data.isDeleted.validate())
                                  return Container(
                                    width: getWidth(context),
                                    child: Stack(
                                      children: [
                                        CachedImageWidget(
                                          url: data.image.validate(),
                                          width: getWidth(context),
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(defaultRadius),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.mirror),
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                margin: EdgeInsets.all(4),
                                                child: Icon(Icons.delete, color: colorPrimary, size: 18),
                                              ),
                                            ),
                                          ).paddingAll(4).onTap(() async {
                                            await showConfirmDialogCustom(
                                              context,
                                              primaryColor: colorPrimary,
                                              cancelable: false,
                                              onCancel: (c) {
                                                finish(c);
                                              },
                                              title: language!.areYouSureYouWantToDeleteThisMovieFromDownloads,
                                              onAccept: (_) async {
                                                try {
                                                  addOrRemoveFromLocalStorage(data, isDelete: true);
                                                  finish(context);
                                                } catch (e) {
                                                  finish(context);
                                                  log("Error : ${e.toString()}");
                                                }
                                              },
                                            );
                                          }),
                                        ),
                                        Observer(
                                          builder: (_) => Positioned(
                                            child: Container(
                                              width: getWidth(context),
                                              height: 200,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: FractionalOffset.topCenter,
                                                  end: FractionalOffset.bottomCenter,
                                                  colors: [
                                                    ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)),
                                                  ],
                                                ),
                                              ),
                                              child: itemTitle(
                                                context,
                                                parseHtmlString(data.title.validate()),
                                                fontSize: ts_small,
                                                textAlign: TextAlign.justify,
                                              ).paddingBottom(8),
                                              alignment: AlignmentDirectional.bottomCenter,
                                            ),
                                            bottom: 0,
                                          ).visible(appStore.showItemName),
                                        )
                                      ],
                                    ),
                                  ).onTap(() async {
                                    if (await checkPermission()) LocalMediaPlayerScreen(data: data).launch(context);
                                  });
                                else
                                  return Offstage();
                              },
                            )
                          ],
                        ),
                      16.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(height: 0, thickness: 1),
                          SettingSection(
                            title: Text(language!.manageAccount, style: boldTextStyle(size: 20, color: Colors.white)),
                            headingDecoration: BoxDecoration(color: Colors.black),
                            items: [
                              SettingWidget(
                                title: language!.playlists,
                                subTitle: language!.watchYourNextList,
                                titleTextStyle: primaryTextStyle(color: Colors.white),
                                leading: CachedImageWidget(
                                  url: ic_add_playlist,
                                  height: 18,
                                  width: 18,
                                  color: context.iconColor,
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                onTap: () {
                                  if (appStore.isLogging) {
                                    PlayListScreen().launch(context);
                                  } else {
                                    SignInScreen(
                                      redirectTo: () {
                                        PlayListScreen().launch(context);
                                      },
                                    ).launch(context);
                                  }
                                },
                              ),
                              SettingWidget(
                                title: language!.notifications,
                                titleTextStyle: primaryTextStyle(color: Colors.white),
                                subTitle: language!.viewTheNewArrivals,
                                leading: Stack(
                                  fit: StackFit.loose,
                                  clipBehavior: Clip.none,
                                  children: [
                                    CachedImageWidget(
                                      url: ic_notification,
                                      width: 18,
                                      height: 18,
                                      color: context.iconColor,
                                    ),
                                    if (notification > 0)
                                      Positioned(
                                        right: -2,
                                        top: -6,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                          child: Text(notification.toString(), style: secondaryTextStyle(size: 9, color: Colors.white)),
                                          decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                                  ).then((_) {
                                    getNotificationCount();
                                  });
                                },

                              ),
                              SettingWidget(
                                title: language!.manageDevices,
                                subTitle: language!.youCanManageUnfamilier,
                                titleTextStyle: primaryTextStyle(color: Colors.white),
                                leading: CachedImageWidget(
                                  url: ic_security,
                                  height: 18,
                                  width: 18,
                                  color: context.iconColor,
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                onTap: () {
                                  if (appStore.isLogging) {
                                    ManageDevicesScreen().launch(context);
                                  } else {
                                    SignInScreen(
                                      redirectTo: () {
                                        ManageDevicesScreen().launch(context);
                                      },
                                    ).launch(context);
                                  }
                                },
                              ),
                              if (appStore.isLogging)
                                SettingWidget(
                                  title: language!.signOutFromAllDevices,
                                  titleTextStyle: primaryTextStyle(color: Colors.white),
                                  leading: CachedImageWidget(
                                    url: ic_power_off,
                                    height: 20,
                                    width: 20,
                                    color: context.iconColor,
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                  onTap: () {
                                    showConfirmDialogCustom(
                                      context,
                                      title: language!.logOutAllDeviceConfirmation,
                                      primaryColor: colorPrimary,
                                      negativeText: language!.no,
                                      positiveText: language!.yes,
                                      onAccept: (c) async {
                                        await logout(logoutFromAll: true, context: context, isNewTask: true);
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ).paddingBottom(spacing_large)
                    ],
                  ),
                ),
                Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
              ],
            ),
          ),
        );
      },
    );
  }
}