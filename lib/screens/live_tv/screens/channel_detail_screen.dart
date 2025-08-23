import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/view_video/ads_player.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/live_tv/epg_components/epg_grid_component.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/screens/live_tv/screens/view_all_recommended_channels_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/html_widget.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import '../../../models/live_tv/live_channel_detail_model.dart';
import '../../../utils/resources/colors.dart';

class ChannelDetailScreen extends StatefulWidget {
  final int channelId;

  ChannelDetailScreen({required this.channelId});

  @override
  State<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends State<ChannelDetailScreen> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    epgStore.setCurrentChannelId(widget.channelId);
    getChannelDetails(widget.channelId, isInitialLoad: true);
    getEPGDetails();
    epgStore.initializeDates();
    if (epgStore.dates.isNotEmpty) {
      epgStore.setSelectedDateAndIndex(epgStore.dates[1], 1);
    }
  }

  Future<void> getChannelDetails(int channelId, {bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      appStore.setLoading(true);
    }

    try {
      LiveChannelDetails details = await getLiveChannelDetails(channelId: channelId);
      log('Fetched Live Channel: ${details.title}');
      appStore.liveChannelDetails = details;
    } catch (e) {
      log('Error fetching live channel details: $e');
      toast(language.somethingWentWrong);
    } finally {
      if (isInitialLoad) {
        appStore.setLoading(false);
      }
    }
  }

  Future<void> getEPGDetails() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      final tomorrow = now.add(Duration(days: 1));

      final futures = await Future.wait([
        getEPGData(
          channelId: widget.channelId,
          date: DateFormat(DATE_FORMAT_4).format(yesterday),
        ),
        getEPGData(
          channelId: widget.channelId,
          date: DateFormat(DATE_FORMAT_4).format(now),
        ),
        getEPGData(
          channelId: widget.channelId,
          date: DateFormat(DATE_FORMAT_4).format(tomorrow),
        ),
      ]);

      final yesterdayData = futures[0];
      final todayData = futures[1];
      final tomorrowData = futures[2];

      epgStore.setEpgData(
        yesterday: yesterdayData,
        today: todayData,
        tomorrow: tomorrowData,
      );
      epgStore.setCurrentChannelId(widget.channelId);
      setState(() {});
    } catch (e) {
      log('Failed to load EPG data: $e');
    }
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getChannelDetails(widget.channelId);
      },
      child: SafeArea(
        child: PiPBuilder(
          builder: (statusInfo) {
            appStore.setPIPOn(statusInfo?.status == PiPStatus.enabled);
            return Scaffold(
              appBar: (statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen)
                  ? AppBar(
                      backgroundColor: context.scaffoldBackgroundColor,
                      elevation: 0,
                      leading: const BackButton(color: Colors.white),
                      centerTitle: false,
                      automaticallyImplyLeading: true,
                      systemOverlayStyle: defaultSystemUiOverlayStyle(context),
                      surfaceTintColor: context.scaffoldBackgroundColor,
                    )
                  : null,
              resizeToAvoidBottomInset: true,
              body: Observer(builder: (context) {
                if (appStore.isLoading) {
                  return Center(child: LoaderWidget());
                }
                LiveChannelDetails? channel = appStore.liveChannelDetails;
                if (channel == null) {
                  return NoDataWidget();
                }
                return ListView(
                  physics: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? ScrollPhysics() : NeverScrollableScrollPhysics(),
                  controller: scrollController,
                  padding: EdgeInsets.only(bottom: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? 30 : 0, top: 0),
                  children: [
                    Container(
                      width: context.width(),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: appStore.isLogging
                            ? ClipRRect(
                                borderRadius: BorderRadius.zero,
                                child: AdVideoPlayerWidget(
                                  streamUrl: channel.videoUrl.validate(),
                                  adConfig: channel.adConfiguration,
                                  title: channel.title.validate(),
                                  isLive: true,
                                  postType: PostType.CHANNEL,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [context.primaryColor.withValues(alpha: 0.8), black.withValues(alpha: 0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 0.55],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      language.loginToWatchMessage,
                                      style: primaryTextStyle(size: 16, color: white),
                                      textAlign: TextAlign.center,
                                    ),
                                    16.height,
                                    AppButton(
                                      color: context.primaryColor,
                                      text: language.login,
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
                              ),
                      ),
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
                                channel.title.validate(),
                                style: boldTextStyle(size: 18, color: white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ).paddingSymmetric(horizontal: 16),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: cardColor, borderRadius: radius(4)),
                                child: Icon(Icons.share_rounded, color: textSecondaryColor, size: 14),
                              ).onTap(() async {
                                await shareMovieOrEpisode(channel.shareUrl.validate());
                              }).paddingRight(16),
                            ],
                          ),
                          16.height,
                          if (channel.description.validate().contains('href') || channel.description.validate().contains('img'))
                            HtmlWidget(
                              postContent: channel.description.validate(),
                              color: textSecondaryColor,
                              fontSize: 14,
                            ).paddingSymmetric(horizontal: 16, vertical: 16)
                          else
                            ReadMoreText(
                              parse(channel.description.validate()).body!.text,
                              style: secondaryTextStyle(),
                              trimLines: 3,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' ...${language.viewMore}',
                              trimExpandedText: '  ${language.viewLess}',
                            ).paddingSymmetric(horizontal: 16),
                          if (channel.recommendedChannels.validate().isNotEmpty) ...[
                            headingWidViewAll(
                              context,
                              language.recommendedChannels,
                              showViewMore: channel.recommendedChannels!.length > 6,
                              callback: () {
                                ViewAllRecommendedChannelsScreen(
                                  recommendedChannels: channel.recommendedChannels!,
                                ).launch(context);
                              },
                            ),
                            HorizontalList(
                              padding: EdgeInsets.only(right: 16, left: 16),
                              itemCount: channel.recommendedChannels!.length > 6 ? 6 : channel.recommendedChannels!.length,
                              itemBuilder: (context, index) {
                                final recommendedChannels = channel.recommendedChannels![index];
                                return Container(
                                  width: context.width() / 2 - 22,
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
                                          url: recommendedChannels.thumbnailImage.validate().isNotEmpty ? recommendedChannels.thumbnailImage.validate() : default_image,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ).onTap(() {
                                  ChannelDetailScreen(channelId: recommendedChannels.id.validate()).launch(context);
                                });
                              },
                            ),
                          ],
                          16.height,
                          Text(language.tvGuide, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16),
                          8.height,
                          EPGGridComponent(
                            epgToday: epgStore.todayData,
                            epgYesterday: epgStore.yesterdayData,
                            epgTomorrow: epgStore.tomorrowData,
                            currentChannelId: widget.channelId,
                            onChannelTap: (channelId) {
                              ChannelDetailScreen(channelId: channelId).launch(context);
                            },
                          ),
                        ],
                      ),
                    ]
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}