import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

// ignore: must_be_immutable
class ViewAllContinueWatchingScreen extends StatefulWidget {
  ViewAllContinueWatchingScreen();

  @override
  ViewAllContinueWatchingScreenState createState() => ViewAllContinueWatchingScreenState();
}

class ViewAllContinueWatchingScreenState extends State<ViewAllContinueWatchingScreen> {
  int currentTabIndex = 0;

  List<String> postTypeList = [
    dashboardTypeMovie,
    dashboardTypeEpisode,
    dashboardTypeVideo,
  ];

  Future<List<CommonDataListModel>>? future;

  List<CommonDataListModel> continueWatchList = [];
  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    future = getVideoContinueWatch(
      continueWatchList: continueWatchList,
      type: postTypeList[currentTabIndex],
      page: page,
      lastPageCallback: (p0) {
        setState(() {
          isLastPage = p0;
        });
      },
    ).whenComplete(
      () {
        appStore.setLoading(false);
        setState(() {});
      },
    ).catchError((e) {
      throw e;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.continueWatching, style: primaryTextStyle(color: Colors.white, size: 22)),
        centerTitle: false,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Stack(
        children: [
          SnapHelperWidget(
            future: future,
            loadingWidget: Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
            errorBuilder: (p0) {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: p0,
                subTitle: language.somethingWentWrong,
                retryText: language.refresh,
                onRetry: () {
                  init();
                },
              ).center();
            },
            onSuccess: (data) {
              if (continueWatchList.isEmpty && !appStore.isLoading)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.notFound,
                  retryText: language.watchNow,
                  onRetry: () {
                    finish(context);
                  },
                ).center();
              return AnimatedScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
                physics: AlwaysScrollableScrollPhysics(),
                refreshIndicatorColor: colorPrimary,
                onSwipeRefresh: () {
                  setState(() {
                    page = 1;
                  });
                  return init();
                },
                onNextPage: () {
                  if (!isLastPage) {
                    setState(() {
                      page++;
                    });
                    init();
                  }
                },
                children: [
                  HorizontalList(
                    itemCount: postTypeList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTabIndex = index;
                          });
                          init();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: boxDecorationDefault(
                            color: index == currentTabIndex ? colorPrimary : context.cardColor,
                            boxShadow: [],
                          ),
                          child: Text(postTypeList[index].title(), style: index == currentTabIndex ? boldTextStyle(color: Colors.white) : primaryTextStyle()),
                        ),
                      );
                    },
                  ),
                  24.height,
                  AnimatedWrap(
                    spacing: 8,
                    runSpacing: 8,
                    itemCount: continueWatchList.length,
                    itemBuilder: (p0, index) {
                      CommonDataListModel data = continueWatchList[index];
                      return CommonListItemComponent(
                        data: data,
                        isLandscape: true,
                        isContinueWatch: true,
                        onTap: null,
                        callback: () async {
                          await showConfirmDialogCustom(context,
                              primaryColor: colorPrimary,
                              cancelable: false,
                              onCancel: (c) {
                                finish(c);
                              },
                              title: language.areYouSureYouWantToDeleteThisFromYourContinueWatching,
                              onAccept: (_) async {
                                finish(context);
                                await deleteVideoContinueWatch(postId: data.id.validate(), postType: data.postType).then((v) {
                                  init();
                                  LiveStream().emit(RefreshHome);
                                }).catchError(onError);
                              });
                        },
                      );
                    },
                  )
                ],
              );
            },
          ),
          Observer(
            builder: (_) => LoadingDotsWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}