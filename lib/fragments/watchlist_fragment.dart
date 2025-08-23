import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/config.dart';

import '../main.dart';

class WatchlistFragment extends StatefulWidget {
  static String tag = '/WatchlistFragment';

  @override
  WatchlistFragmentState createState() => WatchlistFragmentState();
}

class WatchlistFragmentState extends State<WatchlistFragment> {
  ScrollController scrollController = ScrollController();

  List<CommonDataListModel> movieList = [];

  int mPage = 1;
  bool mIsLastPage = false;

  int userId = 0;
  bool isError = false;

  BannerAd? bannerAd;
  Random random = Random();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          getList();
        }
      }
    });

    init();
  }

  init() async {
    getList();
    bannerAd = buildBannerAds()..load();
    userId = getIntAsync(USER_ID);
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

  Future<List<CommonDataListModel>> getList() async {
    appStore.setLoading(true);
    getWatchList(page: mPage).then((value) {
      mIsLastPage = value.length != postPerPage;
      if (mPage == 1) movieList.clear();

      movieList.addAll(value);

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      toast(e.toString());
      appStore.setLoading(false);
    });

    return movieList.validate();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    bannerAd!.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        mPage = 1;
        init();
        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.watchList, style: boldTextStyle(color: Colors.white, size: 20)),
          automaticallyImplyLeading: false,
          backgroundColor: context.cardColor,
          centerTitle: false,
          systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        ),
        body: Observer(
          builder: (_) => Stack(
            children: [
              if (movieList.validate().isNotEmpty)
                SizedBox(
                  height: context.height(),
                  width: context.width(),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 65),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: movieList.validate().map((e) {
                            CommonDataListModel data = e;

                            return CommonListItemComponent(
                              data: e,
                              isVerticalList: true,
                              isWatchList: true,
                              refresh: () {
                                mPage = 1;
                                init();
                              },
                              callback: () {
                                if (!mIsLoggedIn) {
                                  SignInScreen(
                                    redirectTo: () {
                                      setState(() {});
                                    },
                                  ).launch(context);
                                  return;
                                } else {
                                  Map req = {
                                    'post_id': data.id.validate(),
                                    'user_id': userId,
                                  };

                                  toast(language.pleaseWait);
                                  watchlistMovie(req).then((value) {
                                    List<CommonDataListModel>? temp = [];
                                    movieList.validate().forEach((element) {
                                      if (element != data) {
                                        temp.add(element);
                                      }
                                    });

                                    movieList = temp;
                                    setState(() {});
                                  }).catchError((e) {
                                    log(e.toString());
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        controller: scrollController,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: AdSize.banner.height.toDouble(),
                          width: context.width(),
                          child: AdWidget(ad: bannerAd!),
                        ).visible(appStore.showAds),
                      ),
                    ],
                  ),
                ).paddingAll(16),
              if (movieList.isEmpty && !appStore.isLoading && !isError)
                NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.yourWatchListIsEmpty,
                  subTitle: language.keepTrackOfEverything,
                ).paddingSymmetric(horizontal: 50).center(),
              if (isError && !appStore.isLoading)
                NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.somethingWentWrong,
                ).center(),
              if (appStore.isLoading && movieList.isEmpty && mPage == 1)
                LoaderWidget()
              else if (appStore.isLoading && mPage > 1)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 8,
                  child: LoadingDotsWidget(),
                ),
            ],
          ).makeRefreshable,
        ),
      ),
    );
  }
}
