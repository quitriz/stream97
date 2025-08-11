import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/episode_item_component.dart';
import 'package:streamit_flutter/components/view_video/ads_player.dart';
import 'package:streamit_flutter/components/view_video/video_content_widget.dart';

import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/comment_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/movie_detail_like_watchlist_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/post_restriction_component.dart';
import 'package:streamit_flutter/screens/movie_episode/components/sources_data_widget.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/html_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../../../components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';

class EpisodeDetailScreen extends StatefulWidget {
  static String tag = '/EpisodeDetailScreen';
  final String? title;
  final MovieData? episode;
  final List<MovieData>? episodes;
  final int? index;
  final int? lastIndex;
  final String watchedTime;

  EpisodeDetailScreen({
    this.title,
    this.episode,
    this.episodes,
    this.index,
    this.lastIndex,
    this.watchedTime = '',
  });

  @override
  EpisodeDetailScreenState createState() => EpisodeDetailScreenState();
}

class EpisodeDetailScreenState extends State<EpisodeDetailScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  UniqueKey key = UniqueKey();

  bool showComments = false;
  String restrictedPlans = '';
  bool isSharing = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  late MovieData data;
  late int episodeIndex;

  double selectedRating = 0;

  @override
  void initState() {
    requestPipAvailability();
    ScreenProtector.preventScreenshotOn();
    episodeIndex = widget.index.validate();
    data = widget.episode!;
    showComments = appStore.showEpisodeComment;

    init();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> init() async {
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    afterBuildCreated(() {
      getEpisodeDetails(data.id.validate());
    });
  }

  void getEpisodeDetails(int episodeId) async {
    appStore.setLoading(true);
    await getEpisodeDetail(episodeId).then((value) {
      data = value;
      if (value.subscriptionLevels.validate().isNotEmpty) {
        value.subscriptionLevels.validate().forEach((element) {
          restrictedPlans = restrictedPlans +
              '${restrictedPlans.isEmpty ? '' : ','} ${element.label}';
        });
      }
      appStore.setLoading(false);
      key = UniqueKey();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> requestPipAvailability() async {
    appStore.setShowPIP(await FlPiP().isAvailable);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (appStore.isLoading) appStore.setLoading(false);
    appStore.setToFullScreen(false);
    ScreenProtector.preventScreenshotOff();
    appStore.setShowPIP(false);
    super.dispose();
  }

  Widget subscriptionEpisode(MovieData _episode) {
    if (data.userHasAccess.validate()) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy <= 0 && details.delta.dx == 0) {
            _controller.forward();
          }
          if (details.delta.dy >= 0 && details.delta.dx == 0) {
            _controller.reverse();
          }
        },
        child: SizedBox(
          height: !appStore.showPIP && !appStore.hasInFullScreen
              ? context.height() * 0.3
              : context.height(),
          width: context.width(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if ((_episode.adConfiguration != null &&
                  (_episode.episodeFile.validate().isNotEmpty ||
                      _episode.file.validate().isNotEmpty)))
                AdVideoPlayerWidget(
                  streamUrl: _episode.episodeFile.validate().isNotEmpty
                      ? _episode.episodeFile.validate()
                      : _episode.file.validate(),
                  adConfig: _episode.adConfiguration,
                  title: _episode.title.validate(),
                  isLive: false,
                )
              else
                VideoContentWidget(
                  choice: _episode.choice.validate(),
                  image: _episode.image.validate(),
                  urlLink: _episode.urlLink.validate().replaceAll(r'\/', '/'),
                  embedContent: _episode.embedContent,
                  fileLink: _episode.episodeFile.validate().isNotEmpty
                      ? _episode.episodeFile.validate()
                      : _episode.file.validate(),
                  videoId: _episode.id.validate().toString(),
                  watchedTime: widget.watchedTime.toString(),
                  title: _episode.title.validate(),
                  postType: _episode.postType != null
                      ? _episode.postType!
                      : PostType.EPISODE,
                ),
              if (!appStore.showPIP && appStore.hasInFullScreen)
                SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 1.0],
                        tileMode: TileMode.repeated,
                      ),
                    ),
                    child: EpisodeListWidget(
                      widget.episodes.validate(),
                      episodeIndex,
                      onEpisodeChange: (i, episode) {
                        if (appStore.hasInFullScreen) {
                          appStore.setToFullScreen(false);
                          setOrientationPortrait();
                        }
                        if (data.userHasAccess.validate()) {
                          episodeIndex = i;
                          getEpisodeDetails(episode);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return PostRestrictionComponent(
        imageUrl: _episode.image.validate(),
        isPostRestricted: !data.userHasAccess.validate(),
        restrictedPlans: restrictedPlans,
        callToRefresh: () {
          init();
          appStore.setTrailerVideoPlayer(true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PiPBuilder(
        builder: (statusInfo) {
          appStore.setPIPOn(statusInfo?.status == PiPStatus.enabled);
          return Observer(
            builder: (context) {
              return Scaffold(
                appBar: ((statusInfo?.status == PiPStatus.enabled) ||
                        (!data.userHasAccess.validate()) ||
                        appStore.hasInFullScreen ||
                        widget.watchedTime.isNotEmpty)
                    ? null
                    : AppBar(
                        title: Text(parseHtmlString(data.title.validate()),
                            style: boldTextStyle(size: 20)),
                        systemOverlayStyle:
                            defaultSystemUiOverlayStyle(context),
                        surfaceTintColor: context.scaffoldBackgroundColor,
                        elevation: 0,
                        backgroundColor: context.scaffoldBackgroundColor,
                        leading: const BackButton(color: Colors.white),
                      ),
                resizeToAvoidBottomInset: true,
                body: Stack(
                  children: [
                    AnimatedScrollView(
                      physics: statusInfo?.status != PiPStatus.enabled &&
                              !appStore.hasInFullScreen
                          ? ScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      controller: scrollController,
                      padding: EdgeInsets.only(
                          bottom: statusInfo?.status != PiPStatus.enabled &&
                                  !appStore.hasInFullScreen
                              ? 30
                              : 0,
                          top: 0),
                      children: [
                        SizedBox(
                          key: key,
                          child: subscriptionEpisode(data),
                          height: statusInfo?.status != PiPStatus.enabled &&
                                  !appStore.hasInFullScreen
                              ? context.height() * 0.3
                              : context.height(),
                          width: context.width(),
                        ),
                        if (statusInfo?.status != PiPStatus.enabled &&
                            !appStore.hasInFullScreen) ...[
                          8.height,
                          Row(
                            children: [
                              CachedImageWidget(
                                url: data.image.validate(),
                                width: 80,
                                height: 100,
                                fit: BoxFit.fill,
                              ).cornerRadiusWithClipRRect(4),
                              8.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    data.title.validate(),
                                    style: primaryTextStyle(size: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  4.height,
                                  itemSubTitle(
                                    context,
                                    "${data.releaseDate.validate()}",
                                    fontSize: 14,
                                    textColor: Colors.grey.shade500,
                                  ),
                                  4.height,
                                  itemSubTitle(context, data.runTime.validate(),
                                      fontSize: 14,
                                      textColor: Colors.grey.shade500),
                                ],
                              ).expand(),
                            ],
                          ).paddingOnly(
                              left: spacing_standard, right: spacing_standard),
                          if (data.userHasAccess.validate())
                            HtmlWidget(
                              postContent: data.description.validate(),
                              color: textColorSecondary,
                              fontSize: 14,
                            ).paddingAll(8),
                          Divider(thickness: 0.1, color: Colors.grey.shade500)
                              .visible(data.sourcesList.validate().isNotEmpty &&
                                  data.userHasAccess.validate()),
                          MovieDetailLikeWatchListWidget(
                            postId: data.id.validate(),
                            postType: PostType.EPISODE,
                            isInWatchList: data.isInWatchList,
                            isLiked: data.isLiked.validate(),
                            likes: data.likes,
                          ).paddingSymmetric(horizontal: 16),
                          if (data.sourcesList.validate().isNotEmpty &&
                              data.userHasAccess.validate())
                            Text(
                              language!.sources,
                              style: primaryTextStyle(size: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).paddingAll(8),
                          if (data.sourcesList.validate().isNotEmpty &&
                              data.userHasAccess.validate())
                            SourcesDataWidget(
                              sourceList: data.sourcesList,
                              onLinkTap: (sources) async {
                                LiveStream().emit(PauseVideo);
                                data.choice = sources.choice;

                                if (sources.choice == "episode_embed") {
                                  if (sources.embedContent != null) {
                                    if (sources.embedContent!
                                        .contains('<iframe')) {
                                      data.embedContent = sources.embedContent;
                                      data.choice = "episode_embed";
                                    } else if (sources.embedContent!
                                        .contains('http')) {
                                      data.urlLink = sources.embedContent;
                                      data.choice = "episode_url";
                                    }
                                  }
                                }
                                setState(() {});
                              },
                            ).paddingAll(8),
                          Divider(
                            thickness: 0.1,
                            color: Colors.grey.shade500,
                          ).visible(data.sourcesList.validate().isNotEmpty &&
                              data.userHasAccess.validate()),
                          if (showComments &&
                              data.isCommentOpen.validate() &&
                              data.userHasAccess.validate())
                            CommentWidget(
                              postId: data.id,
                              noOfComments: data.noOfComments,
                              postType: PostType.EPISODE,
                              comments: data.comments.validate(),
                            ).paddingAll(16),
                          Divider(thickness: 0.1, color: Colors.grey.shade500)
                              .visible(widget.episodes.validate().isNotEmpty),
                          headingWidViewAll(context, language!.episodes,
                                  showViewMore: false)
                              .paddingOnly(
                                  left: spacing_standard,
                                  right: spacing_standard)
                              .visible(widget.episodes.validate().isNotEmpty),
                          EpisodeListWidget(
                            widget.episodes.validate(),
                            episodeIndex,
                            onEpisodeChange: (i, episode) {
                              if (appStore.hasInFullScreen) {
                                appStore.setToFullScreen(false);
                                setOrientationPortrait();
                              }
                              if (data.userHasAccess.validate()) {
                                episodeIndex = i;
                                getEpisodeDetails(episode);
                              }
                            },
                          ).visible(widget.episodes.validate().isNotEmpty),
                          8.height,
                        ]
                      ],
                    ),
                    Observer(
                            builder: (_) =>
                                LoaderWidget().visible(appStore.isLoading))
                        .center(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EpisodeListWidget extends StatelessWidget {
  final List<MovieData> episodes;
  final Function(int, int)? onEpisodeChange;
  final int index;

  EpisodeListWidget(this.episodes, this.index, {this.onEpisodeChange});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      itemBuilder: (context, i) {
        MovieData episode = episodes[i];

        return EpisodeItemComponent(
          episode: episode,
          callback: () {
            onEpisodeChange?.call(i, episode.id.validate());
          },
        );
      },
    );
  }
}
