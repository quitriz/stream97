import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/episode_detail_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class CommonListItemComponent extends StatelessWidget {
  final CommonDataListModel data;

  final bool isContinueWatch;
  final VoidCallback? callback;
  final VoidCallback? refresh;
  final bool isVerticalList;
  final bool isWatchList;
  final double? width;
  final VoidCallback? onTap;
  final bool isLandscape;
  final bool isLive;

  CommonListItemComponent({
    this.callback,
    this.isLandscape = false,
    required this.data,
    this.isContinueWatch = false,
    this.isVerticalList = false,
    this.isWatchList = false,
    this.width,
    this.refresh,
    this.isLive = false,
    this.onTap,
  });

  void _handleOnTap(BuildContext context) async {
    LiveStream().emit(PauseVideo);

    if (data.postType == PostType.EPISODE) {
      appStore.setTrailerVideoPlayer(!isContinueWatch);
      MovieData episode = MovieData();
      episode.title = data.title;
      episode.image = data.image.validate().isNotEmpty ? data.image : default_image;
      episode.id = data.id;
      episode.postType = PostType.EPISODE;

      await EpisodeDetailScreen(
        episode: episode,
        episodes: [],
        watchedTime: data.watchedDuration != null ? data.watchedDuration!.watchedTime.validate().toString() : '',
      ).launch(context).then((value) {
        if (isWatchList) refresh?.call();
      });
    } else if (data.postType == PostType.CHANNEL) {
      appStore.setTrailerVideoPlayer(false);
      ChannelDetailScreen(channelId: data.id.validate()).launch(context);
    } else {
      appStore.setTrailerVideoPlayer(!isContinueWatch);
      await MovieDetailScreen(movieData: data, isContinueWatching: isContinueWatch).launch(context).then((value) {
        if (isWatchList) refresh?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () async {
            _handleOnTap(context);
          },
      borderRadius: BorderRadius.circular(radius_container),
      child: isLandscape
          ? Stack(
              children: [
                Container(
                  width: width ?? context.width() / 2 - 22,
                  height: context.height() * .12,
                  decoration: boxDecorationDefault(
                    boxShadow: [],
                    borderRadius: radius(),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.mirror,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: width ?? context.width() / 2 - 22,
                  height: context.height() * .12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    child: Stack(
                      children: [
                        CachedImageWidget(
                          url: data.image.validate().isNotEmpty ? data.image.validate() : default_image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        // Bottom gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ),
                            ),
                            child: Align(alignment: Alignment.bottomRight, child: LiveTagComponent()),
                          ),
                        ).visible(isLive && !isContinueWatch),
                      ],
                    ),
                  ),
                ),
                if (isContinueWatch && data.watchedDuration != null)
                  Positioned(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: context.scaffoldBackgroundColor.withValues(alpha: 0.5),
                            child: Text(
                              formatWatchedTime(totalSeconds: data.watchedDuration!.watchedTotalTime.validate(), watchedSeconds: data.watchedDuration!.watchedTime.validate()),
                              style: secondaryTextStyle(size: 12),
                            ),
                          ),
                        ),
                        4.height,
                        LinearPercentIndicator(
                          animation: false,
                          lineHeight: 2,
                          percent: data.watchedDuration!.watchedTimePercentage / 100,
                          progressColor: context.primaryColor,
                          backgroundColor: textColorThird,
                        ),
                      ],
                    ),
                    right: -10,
                    left: -10,
                    bottom: 12,
                  ),
                if (isContinueWatch && data.watchedDuration != null)
                  Positioned(
                    top: 2,
                    right: -4,
                    child: InkWell(
                      onTap: () {
                        callback?.call();
                      },
                      child: Icon(Icons.cancel, color: context.primaryColor, size: 20),
                    ).paddingSymmetric(horizontal: 8, vertical: 4),
                  ),
                if (!isContinueWatch && appStore.showItemName)
                  Positioned(
                    child: Text(
                      data.title.validate(),
                      style: primaryTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                    right: 8,
                    left: 8,
                    bottom: 8,
                  ),
              ],
            )
          : Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: isVerticalList ? getWidth(context) : 140,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CachedImageWidget(
                              url: data.portraitImage.validate().isEmpty ? default_image : data.portraitImage.validate(),
                              height: context.height() - 20,
                              width: context.width(),
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(radius_container),
                            if (isContinueWatch && data.watchedDuration != null)
                              LinearPercentIndicator(
                                animation: false,
                                lineHeight: 2,
                                percent: data.watchedDuration!.watchedTimePercentage.toInt() / 100,
                                progressColor: context.primaryColor,
                                backgroundColor: textColorThird,
                              ).paddingSymmetric(vertical: 8),
                            if (isContinueWatch && data.watchedDuration != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    callback?.call();
                                  },
                                  child: Icon(Icons.cancel, color: context.primaryColor, size: 20),
                                ).paddingSymmetric(horizontal: 8, vertical: 4),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Observer(
                  builder: (_) => Container(
                    height: 200,
                    width: isVerticalList ? getWidth(context) : 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: itemTitle(
                        context,
                        parseHtmlString(data.title.validate()),
                        fontSize: ts_small,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ).visible(appStore.showItemName),
                ),

                ///PPV Icons
                if (!data.isRented.validate() &&
                    data.isRent.validate() &&
                    !(data.requiredPlan != null && appStore.subscriptionPlanId == data.requiredPlan.validate()) &&
                    data.userHasAccess == false &&
                    appStore.isMembershipEnabled)
                  if (data.isRent.validate()) ...[
                    ///Dynamic Icons Handling
                    Positioned(
                      top: 8,
                      right: data.purchaseType == PurchaseType.anyone ? 38 : 8,
                      child: CachedImageWidget(
                        url: data.purchaseType == PurchaseType.anyone
                            ? subscription
                            : data.purchaseType == PurchaseType.ppv
                                ? rent_image
                                : subscription,
                        width: 22,
                        height: 22,
                        color: data.purchaseType == PurchaseType.ppv ? null : subscriptionColor,
                      ),
                    ),
                    if (data.purchaseType == PurchaseType.anyone)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CachedImageWidget(url: rent_image, width: 22, height: 22),
                      ),
                  ],

                ///Rented Icon
                if (data.isRented == true && appStore.isMembershipEnabled)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CachedImageWidget(url: rented_image, width: 22, height: 22),
                  ),
              ],
            ),
    );
  }
}
