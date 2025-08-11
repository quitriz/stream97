import 'dart:async';
import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/view_video/ads_player.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/cast/cast_detail_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/review_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/movie_detail_like_watchlist_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/post_restriction_component.dart';
import 'package:streamit_flutter/screens/movie_episode/components/season_data_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/sources_data_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/upcoming_related_movie_list_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/html_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import '../../auth/sign_in.dart';
import 'episode_detail_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? title;
  CommonDataListModel movieData;
  final int? currentIndex;
  final List<CommonDataListModel>? playList;
  final VoidCallback? onRemoveFromPlaylist;
  final bool isContinueWatching;

  MovieDetailScreen({
    this.title = "",
    required this.movieData,
    this.onRemoveFromPlaylist,
    this.currentIndex,
    this.playList,
    this.isContinueWatching = false,
  });

  @override
  MovieDetailScreenState createState() => MovieDetailScreenState();
}

class MovieDetailScreenState extends State<MovieDetailScreen> {
  ScrollController scrollController = ScrollController();

  late MovieData movie;
  MovieDetailResponse? movieResponse;

  int selectedIndex = 0;
  int currentIndex = 0;
  String genre = '';

  InterstitialAd? interstitialAd;

  PostType? postType;

  bool showComments = false;
  bool isError = false;
  bool hasData = false;
  bool isSharing = false;
  bool isDownloading = false;

  String restrictedPlans = '';

  List<Map<String, List>> castCrewHeaderList = [];
  Map<String, List>? selectedData;

  @override
  void initState() {
    appStore.setTrailerVideoPlayer(!widget.isContinueWatching);
    init();
    super.initState();

    ScreenProtector.preventScreenshotOn();
    requestPipAvailability();
  }

  Future<void> init() async {
    setState(() {
      movie = MovieData(
        image: widget.movieData.image,
        title: widget.movieData.title,
        id: widget.movieData.id,
        postType: widget.movieData.postType,
        trailerLink: widget.movieData.trailerLink.validate(),
      );
      currentIndex = widget.currentIndex ?? 0;

      if (widget.playList.validate().isNotEmpty) {
        CommonDataListModel data = widget.playList.validate()[currentIndex];
        movie = MovieData(image: data.image, title: data.title, id: data.id, postType: data.postType);
      }
      postType = movie.postType!;
    });
    appStore.setLoading(true);

    try {
      await getDetails();
      await getReview();
    } catch (e) {
      isError = true;
    } finally {
      appStore.setLoading(false);
    }

    if (adShowCount < 5) {
      adShowCount++;
    } else {
      adShowCount = 0;
      buildInterstitialAd();
    }
  }

  Future<void> getReview() async {
    String type = '';
    switch (movie.postType) {
      case PostType.MOVIE:
        type = 'movie';
        break;
      case PostType.TV_SHOW:
        type = 'tv_show';
        break;
      case PostType.EPISODE:
        type = 'episode';
        break;
      case PostType.VIDEO:
        type = 'video';
        break;
      default:
        type = 'movie';
    }
    final reviews = await getReviewList(postType: type.toLowerCase(), postId: widget.movieData.id.validate());
    appStore.reviewList.clear();
    appStore.reviewList.addAll(reviews);
  }

  Future<void> requestPipAvailability() async {
    appStore.setShowPIP(await FlPiP().isAvailable);
  }

  Future<MovieDetailResponse?> getDetailAPIByType() async {
    if (widget.movieData.postType == PostType.MOVIE) {
      setState(() {
        showComments = appStore.showMovieComments;
      });
      return movieDetail(movie.id.validate());
    } else if (widget.movieData.postType == PostType.TV_SHOW) {
      setState(() {
        showComments = appStore.showTVShowComments;
      });
      return tvShowDetail(movie.id.validate());
    } else if (widget.movieData.postType == PostType.EPISODE) {
      setState(() {
        showComments = appStore.showEpisodeComment;
      });
      return episodeDetail(movie.id.validate());
    } else if (widget.movieData.postType == PostType.VIDEO) {
      setState(() {
        showComments = appStore.showVideoComments;
      });
      return getVideosDetail(movie.id.validate());
    } else {
      return null;
    }
  }

  Future<void> getDetails() async {
    try {
      final value = await getDetailAPIByType();
      if (value != null) {
        movieResponse = value;
        widget.movieData.isUpcoming = value.data?.isUpcoming.validate() ?? true;
        hasData = true;
        movie = value.data ?? MovieData();
        castCrewHeaderList.clear();

        if (movie.castsList.validate().isNotEmpty) {
          castCrewHeaderList.add({'Casts': movie.castsList.validate()});
        }
        if (movie.crews.validate().isNotEmpty) {
          castCrewHeaderList.add({'Crews': movie.crews.validate()});
        }

        if (value.data?.genre != null) {
          genre = '';
          value.data!.genre!.forEach((element) {
            if (genre.isNotEmpty) {
              genre = '$genre • ${element.validate()}';
            } else {
              genre = element.validate();
            }
          });
        }

        if (value.data != null) movie = value.data!;

        if (value.data!.trailerLink.validate().isNotEmpty && !widget.isContinueWatching) {
          appStore.setTrailerVideoPlayer(true);
        }

        if (value.data!.subscriptionLevels.validate().isNotEmpty && !value.data!.userHasAccess.validate()) {
          value.data!.subscriptionLevels!.forEach((element) {
            restrictedPlans = restrictedPlans + '${restrictedPlans.isEmpty ? '' : ','} ${element.label}';
          });
        }
        setState(() {});
      }
    } catch (e) {
      hasData = false;
      isError = true;
      setState(() {});
    }
  }

  Future<void> playFirstEpisode() async {
    if (!movie.userHasAccess.validate()) {
      toast(language!.youDontHaveMembership);
      return;
    }

    final seasons = movie.seasons?.data.validate();
    if (seasons == null || seasons.isEmpty) {
      toast('No seasons available.');
      return;
    }
    final firstSeason = seasons.first;

    try {
      appStore.setLoading(true);
      final seasonDetail = await tvShowSeasonDetail(
        showId: movie.id.validate(),
        seasonId: firstSeason.id.validate().toInt(),
        page: 1,
      );
      appStore.setLoading(false);

      final eps = seasonDetail.episodes.validate();
      if (eps.isNotEmpty) {
        EpisodeDetailScreen(
          title: eps[0].title.validate(),
          episode: eps[0],
          episodes: eps,
          index: 0,
          lastIndex: eps.length,
        ).launch(context);
      } else {
        toast('No episodes found.');
      }
    } catch (e) {
      appStore.setLoading(false);
      log('Error loading first episode: $e');
      toast('Failed to load episodes.');
    }
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        buildInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        buildInterstitialAd();
      },
    );
    interstitialAd!.show();
  }

  void buildInterstitialAd() {
    InterstitialAd.load(
      adUnitId: mAdMobInterstitialId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          this.interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  double roundDouble({required double value, int? places}) => ((value * 10).round().toDouble() / 10);

  Widget movieStreamingWidget(MovieData movie) {
    log('AD Config: ${movie.adConfiguration?.adsEnabled}, Pre-roll: ${movie.adConfiguration?.preRollAdsList?.length}, Mid-roll: ${movie.adConfiguration?.midRollAdsList?.length}');
    return AdVideoPlayerWidget(
      streamUrl: movie.file.validate(),
      adConfig: movie.adConfiguration,
      title: movie.title.validate(),
      isLive: false,
    );
  }

  Widget subscriptionWidget() {
    return Observer(
      builder: (context) {
        if (appStore.isTrailerVideoPlaying) {
          return VideoWidget(
            thumbnailImage: movie.image.validate(),
            videoURL: movie.trailerLink.validate(),
            videoURLType: movie.trailerLinkType.validate(),
            videoType: widget.movieData.postType,
            videoId: movie.id.validate(),
            isTrailer: true,
            watchedTime: '',
            onTap: () {},
          );
        } else if (!movie.userHasAccess.validate()) {
          return PostRestrictionComponent(
            imageUrl: movie.image.validate(),
            isPostRestricted: !movie.userHasAccess.validate(),
            restrictedPlans: restrictedPlans,
            callToRefresh: () {
              init();
              appStore.setTrailerVideoPlayer(true);
            },
          );
        } else if (!appStore.isLogging) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.primaryColor.withValues(alpha: 0.8), Colors.black.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.55],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language!.loginToWatchMessage,
                  style: primaryTextStyle(size: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                16.height,
                AppButton(
                  color: context.primaryColor,
                  text: language!.login,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  onTap: () {
                    SignInScreen(
                      redirectTo: () {
                        setState(() {});
                      },
                    ).launch(context);
                  },
                ),
              ],
            ),
          );
        } else {
          return movieStreamingWidget(movie);
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setTrailerVideoPlayer(true);
    if (scrollController.hasClients) scrollController.dispose();
    if (!disabledAds) showInterstitialAd();
    ScreenProtector.preventScreenshotOff();
    appStore.setToFullScreen(false);
    appStore.setShowPIP(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getDetails();
        getReview();
        return await 2.seconds.delay;
      },
      child: SafeArea(
        child: PiPBuilder(
          builder: (statusInfo) {
            appStore.setPIPOn(statusInfo?.status == PiPStatus.enabled);
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: (statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen)
                  ? AppBar(
                      backgroundColor: context.scaffoldBackgroundColor,
                      elevation: 0,
                      leading: const BackButton(color: Colors.white),
                      title: null,
                      centerTitle: false,
                      automaticallyImplyLeading: true,
                      systemOverlayStyle: defaultSystemUiOverlayStyle(context),
                      surfaceTintColor: context.scaffoldBackgroundColor,
                    )
                  : null,
              body: Stack(
                children: [
                  if (hasData && !isError)
                    Observer(
                      builder: (context) {
                        return AnimatedScrollView(
                          physics: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? ScrollPhysics() : NeverScrollableScrollPhysics(),
                          controller: scrollController,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          padding: EdgeInsets.only(bottom: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? 30 : 0, top: 0),
                          children: [
                            SizedBox(
                              child: subscriptionWidget(),
                              height: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? context.height() * 0.3 : context.height(),
                              width: context.width(),
                            ),
                            if (statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen) ...[
                              4.height,
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        parseHtmlString(movie.title.validate()),
                                        style: primaryTextStyle(size: 30),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: cardColor, borderRadius: radius(4)),
                                        child: Icon(Icons.share_rounded, color: textSecondaryColor, size: 18),
                                      ).onTap(() async {
                                        await shareMovieOrEpisode(movie.shareUrl.validate());
                                      }).paddingRight(16),
                                    ],
                                  ),
                                  8.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (movie.releaseDate.validate().isNotEmpty)
                                        Text(
                                          movie.releaseDate.validate(),
                                          style: secondaryTextStyle(size: 14),
                                        ),
                                      if (genre.isNotEmpty) ...[
                                        4.height,
                                        Text(
                                          genre,
                                          style: secondaryTextStyle(size: 14),
                                        ),
                                      ],
                                      if (movie.runTime.validate().isNotEmpty) ...[
                                        4.height,
                                        Text(
                                          movie.runTime.validate(),
                                          style: secondaryTextStyle(size: 14),
                                        ),
                                      ],
                                      4.height,
                                      Text(
                                        'English',
                                        style: secondaryTextStyle(size: 14),
                                      ),
                                    ],
                                  ),
                                  16.height,

                                  /// Stream_now_Button
                                  if (appStore.isTrailerVideoPlaying && widget.movieData.isUpcoming == false)
                                    Container(
                                      height: 45,
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                        color: colorPrimary,
                                        borderRadius: radius(4),
                                      ),
                                      child: TextIcon(
                                        text: language!.streamNow,
                                        textStyle: boldTextStyle(color: Colors.white),
                                        suffix: Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                                      ).center(),
                                    ).onTap(() {
                                      if (appStore.isLogging) {
                                        appStore.setTrailerVideoPlayer(false);
                                      } else {
                                        SignInScreen(
                                          redirectTo: () {
                                            setState(() {});
                                          },
                                        ).launch(context);
                                      }
                                    }),
                                  16.height,
                                  if (movie.tag != null && movie.tag!.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: movie.tag!.map((tag) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius: radius(4),
                                          ),
                                          child: Text(
                                            tag,
                                            style: secondaryTextStyle(size: 12),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  8.height,
                                ],
                              ).paddingSymmetric(horizontal: 16),
                              if (movie.description.validate().isNotEmpty && movie.userHasAccess.validate())
                                if (movie.description.validate().contains('href') || movie.description.validate().contains('img'))
                                  HtmlWidget(
                                    postContent: movie.description.validate(),
                                    color: textSecondaryColor,
                                    fontSize: 14,
                                  ).paddingSymmetric(horizontal: 16, vertical: 16)
                                else
                                  ReadMoreText(
                                    parse(movie.description.validate()).body!.text,
                                    style: secondaryTextStyle(),
                                    trimLines: 3,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: ' ...${language!.viewMore}',
                                    trimExpandedText: '  ${language!.viewLess}',
                                  ).paddingSymmetric(horizontal: 16, vertical: 16),
                              8.height,
                              MovieDetailLikeWatchListWidget(
                                postId: movie.id.validate(),
                                postType: movie.postType!,
                                isInWatchList: movie.isInWatchList,
                                isLiked: movie.isLiked.validate(),
                                likes: movie.likes,
                                videoName: movie.title.validate(),
                                videoLink: movie.file.validate(),
                                videoImage: movie.image.validate(),
                                videoDescription: movie.description.validate(),
                                videoDuration: movie.runTime.validate(),
                                userHasAccess: movie.userHasAccess.validate(),
                                isTrailerVideoPlaying: appStore.isTrailerVideoPlaying,
                                onAction: () {
                                  widget.onRemoveFromPlaylist?.call();
                                  setState(() {});
                                },
                              ).paddingSymmetric(horizontal: 16),
                              Observer(builder: (context) {
                                return ReviewWidget(
                                  postType: movie.postType!.name.validate(),
                                  postId: movie.id,
                                  callReviewList: () {
                                    getReview();
                                  },
                                ).paddingAll(16).visible(movie.isCommentOpen.validate() && appStore.isLogging);
                              }),
                              Divider(thickness: 0.1, color: Colors.grey.shade500).visible(hasData),
                              if (castCrewHeaderList.isNotEmpty) ...[
                                16.height,
                                Wrap(
                                  children: List.generate(
                                    castCrewHeaderList.length,
                                    (index) {
                                      bool isSelected = selectedIndex == index;
                                      selectedData = castCrewHeaderList[selectedIndex];
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        decoration: boxDecorationDefault(
                                          color: context.cardColor,
                                          borderRadius: radius(24),
                                          border: Border.all(color: isSelected ? context.primaryColor : Colors.grey.shade800, width: 1),
                                          boxShadow: [],
                                        ),
                                        child: Text(castCrewHeaderList[index].keys.first, style: primaryTextStyle()),
                                      ).onTap(
                                        () {
                                          selectedIndex = index;
                                          selectedData = castCrewHeaderList[selectedIndex];
                                          setState(() {});
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      );
                                    },
                                  ),
                                  runSpacing: 16,
                                  spacing: 16,
                                ).paddingSymmetric(horizontal: 16),
                                Wrap(
                                  children: selectedData!.values.map((e) {
                                    return HorizontalList(
                                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                                      itemCount: e.length,
                                      itemBuilder: (context, index) {
                                        CommonModelMovieDetail data = e[index];
                                        return Container(
                                          width: 100,
                                          child: Column(
                                            children: [
                                              CachedImageWidget(
                                                url: data.image.validate().isEmpty ? default_image : data.image.validate(),
                                                fit: BoxFit.cover,
                                                width: 70,
                                                height: 70,
                                              ).cornerRadiusWithClipRRect(60).paddingOnly(left: 4, right: 4),
                                              4.height,
                                              Text(
                                                data.name.validate(),
                                                style: primaryTextStyle(),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ).onTap(() async {
                                            await CastDetailScreen(castId: data.id.validate()).launch(context);
                                          }, borderRadius: BorderRadius.circular(defaultRadius), highlightColor: Colors.transparent),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ).visible(selectedData != null),
                              ],
                              Divider(thickness: 0.1, color: Colors.grey.shade500).visible(selectedData != null),
                              if (hasData && movie.postType != PostType.TV_SHOW && movie.sourcesList.validate().isNotEmpty && movie.userHasAccess.validate())
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language!.sources,
                                      style: primaryTextStyle(size: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).paddingOnly(right: 16, left: 16, top: 16),
                                    SourcesDataWidget(
                                      sourceList: movie.sourcesList,
                                      onLinkTap: (sources) async {
                                        LiveStream().emit(PauseVideo);
                                        movie.choice = sources.choice;
                                        if (sources.choice == "movie_url") {
                                          movie.urlLink = sources.link;
                                        } else if (sources.choice == "movie_embed") {
                                          movie.embedContent = sources.embedContent;
                                        }
                                        appStore.setTrailerVideoPlayer(false);
                                        finish(context);
                                        await MovieDetailScreen(movieData: widget.movieData).launch(context);
                                      },
                                    ).paddingSymmetric(horizontal: 12, vertical: 16),
                                    Divider(thickness: 0.1, color: Colors.grey.shade500),
                                  ],
                                ),
                              if (hasData && movie.postType == PostType.TV_SHOW && movie.seasons!.count != null && widget.movieData.isUpcoming == false)
                                SeasonDataWidget(
                                  hasUserAccess: movie.userHasAccess.validate(),
                                  movieSeason: movie.seasons,
                                  postId: movie.id.validate(),
                                  scrollController: scrollController,
                                  dropdownValue: movie.seasons!.data.validate()[0],
                                ),
                              if (hasData) UpcomingRelatedMovieListWidget(snap: movieResponse),
                            ]
                          ],
                        );
                      },
                    ),
                  if (!hasData && isError)
                    NoDataWidget(
                      imageWidget: noDataImage(),
                      title: language!.noDataFound,
                    ).center(),
                  Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)).center(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
