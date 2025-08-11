import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home/movie_grid_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/utils/constants.dart';

// ignore: must_be_immutable
class ViewAllMoviesScreen extends StatefulWidget {
  static String tag = '/ViewAllMoviesScreen';
  int index;
  String? type;
  String? title;
  List<dynamic>? typeId = [];
  final PostType postType;

  ViewAllMoviesScreen(this.index, this.type, this.title, this.typeId, {this.postType = PostType.MOVIE});

  @override
  ViewAllMoviesScreenState createState() => ViewAllMoviesScreenState();
}

class ViewAllMoviesScreenState extends State<ViewAllMoviesScreen> {
  List<CommonDataListModel> movies = [];
  ScrollController scrollController = ScrollController();

  BannerAd? bannerAd;

  int page = 1;

  bool isLoading = true;
  bool loadMore = true;
  bool hasError = false;

  String title = '';

  PostType mapStringToPostType(String postType) {
    switch (postType.toLowerCase()) {
      case 'movie':
        return PostType.MOVIE;
      case 'tv_show':
        return PostType.TV_SHOW;
      case 'episode':
        return PostType.EPISODE;
      case 'live_tv':
        return PostType.CHANNEL;
      case 'video':
        return PostType.VIDEO;
      default:
        return PostType.NONE;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (loadMore) {
          page++;
          isLoading = true;

          setState(() {});

          init();
        }
      }
    });
  }

  Future<void> init() async {
    bannerAd = buildBannerAds()..load();
    viewAll(
      widget.index,
      widget.type ?? dashboardTypeHome,
      page: page,
      list: (widget.typeId is List) ? widget.typeId : [],
      postType: widget.postType,
    ).then((value) {
      isLoading = false;

      if (page == 1) movies.clear();
      loadMore = value.data!.length == postPerPage;

      title = widget.title.validate();

      movies.addAll(value.data!);

      setState(() {});
    }).catchError((e) {
      log(e);
      isLoading = false;
      hasError = true;

      toast(e.toString());
      setState(() {});
    });
  }

  BannerAd buildBannerAds() {
    return BannerAd(
      size: AdSize.banner,
      request: AdRequest(),
      adUnitId: mAdMobBannerId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        //
      }),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    bannerAd!.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? title, style: primaryTextStyle(color: Colors.white, size: 22)), centerTitle: false, backgroundColor: Theme.of(context).cardColor),
      body: Container(
        height: context.height(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 70),
              child: MovieGridList(movies),
              controller: scrollController,
            ),
            if (page == 1)
              LoaderWidget().center().visible(isLoading)
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: LoadingDotsWidget(),
              ).visible(isLoading),
            NoDataWidget(
              imageWidget: noDataImage(),
              title: '$title ${language!.notFound}',
              subTitle: '${language!.the} $title ${language!.hasNotYetBeenAdded}',
            ).center().visible(!isLoading && movies.isEmpty && !hasError),
            Text(errorSomethingWentWrong, style: boldTextStyle(color: Colors.white)).center().visible(hasError),
            if (bannerAd != null && appStore.showAds)
              Positioned(
                child: Container(color: Colors.white, child: AdWidget(ad: bannerAd!)),
                bottom: 0,
                height: AdSize.banner.height.toDouble(),
                width: context.width(),
              )
          ],
        ),
      ),
    );
  }
}
