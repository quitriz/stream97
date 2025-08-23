import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/dashboard_response.dart' as Model;
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home/dashboard_slider_widget.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';
import 'package:streamit_flutter/screens/home/view_all_continue_watchings_screen.dart';
import 'package:streamit_flutter/screens/home/view_all_movies_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/cached_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class SubHomeFragment extends StatefulWidget {
  static String tag = '/SubHomeFragment';
  final String? type;

  SubHomeFragment({this.type});

  @override
  SubHomeFragmentState createState() => SubHomeFragmentState();
}

class SubHomeFragmentState extends State<SubHomeFragment> with AutomaticKeepAliveClientMixin {
  late Future<Model.DashboardResponse> future;

  @override
  void initState() {
    ScreenProtector.preventScreenshotOn();
    init();

    super.initState();
    LiveStream().on(RefreshHome, (p0) {
      init();
    });
  }

  Future<void> init() async {
    future = getDashboardData({}, type: widget.type.validate(value: dashboardTypeHome)).then((v) {
      DashboardCachedData.storeData(dashboardTypeKey: widget.type.validate(), data: v.toJson());
      setState(() {});

      return v;
    }).catchError((e) {
      throw e;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  PostType detectPostTypeFromSlider(Model.Slider slider) {
    try {
      return slider.data.validate().isNotEmpty ? slider.data!.first.postType : PostType.NONE;
    } catch (e) {
      log("Failed to detect postType for slider '${slider.title}': $e");
      return PostType.NONE;
    }
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
    LiveStream().dispose(RefreshHome);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        init();
        await 2.seconds.delay;
        return Future.value(true);
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.topCenter,
          child: SnapHelperWidget<Model.DashboardResponse>(
            initialData: DashboardCachedData.getData(dashboardTypeKey: widget.type.validate()),
            future: future,
            errorBuilder: (p0) {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: '${language.noData}',
                subTitle: language.somethingWentWrong,
              );
            },
            onSuccess: (data) {
              if (data.banner.validate().isEmpty && data.sliders.validate().isEmpty && data.continueWatch.validate().isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: '${language.no} ${widget.type.validate() == 'home' ? '${language.content}' : widget.type.validate()} ${language.found}',
                  subTitle: '${language.the} ${widget.type.validate() == 'home' ? '${language.content}' : widget.type.validate()} ${language.hasNotYetBeenAdded}',
                );
              return Observer(builder: (context) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.banner.validate().isNotEmpty)
                        DashboardSliderWidget(
                          mSliderList: data.banner.validate(),
                          key: ValueKey(widget.type),
                        ),
                      if (data.continueWatch.validate().isNotEmpty && appStore.isLogging)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headingWidViewAll(
                              context,
                              language.continueWatching,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              showViewMore: data.continueWatch.validate().length > 4,
                              callback: () async {
                                LiveStream().emit(PauseVideo);
                                ViewAllContinueWatchingScreen().launch(context);
                              },
                            ),
                            ItemHorizontalList(
                              data.continueWatch.validate(),
                              isContinueWatch: true,
                              isLandscape: true,
                              isLiveTv: false,
                              refreshContinueWatchList: () {
                                init();
                              },
                            ),
                          ],
                        ).visible(!appStore.hasInFullScreen),
                      Column(
                        children: data.sliders.validate().map((e) {
                          if (e.data.validate().isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                headingWidViewAll(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  context,
                                  e.title.validate(),
                                  callback: () async {
                                    LiveStream().emit(PauseVideo);
                                    await ViewAllMoviesScreen(data.sliders!.indexOf(e), e.type.toString(), e.title.validate(), e.type.toString() != 'latest' ? e.ids : [],
                                            postType: detectPostTypeFromSlider(e))
                                        .launch(context);
                                  },
                                  showViewMore: e.viewAll.validate(),
                                ),
                                ItemHorizontalList(
                                  e.data.validate(),
                                  isTop10: e.type.validate() == 'top_ten',
                                  isContinueWatch: false,
                                  isLandscape: e.postType == PostType.CHANNEL,
                                  isLiveTv: e.postType == PostType.CHANNEL,
                                ),
                              ],
                            );
                          } else {
                            return Offstage();
                          }
                        }).toList(),
                      ).visible(!appStore.hasInFullScreen),
                    ],
                  ),
                );
              });
            },
          ).makeRefreshable,
        ),
      ),
    );
  }
}
