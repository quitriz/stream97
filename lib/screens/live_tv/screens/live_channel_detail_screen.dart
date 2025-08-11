import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/generated/assets.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../../../components/cached_image_widget.dart';

import '../../../main.dart';
import '../../../models/live_tv/live_channel_detail_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/common.dart';
import '../../../utils/resources/colors.dart';

class LiveChannelDetailScreen extends StatefulWidget {
  final ChannelData channelData;

  LiveChannelDetailScreen({Key? key, required this.channelData}) : super(key: key);

  @override
  _LiveChannelDetailScreenState createState() => _LiveChannelDetailScreenState();
}

class _LiveChannelDetailScreenState extends State<LiveChannelDetailScreen> {
  ScrollController controller = ScrollController();
  late ChannelData channelData;

  Future<ChannelData?>? future;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init({bool showLoader = true}) async {
    await getChannelData();
  }

  Future<void> getChannelData({int? channelId, bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    future = getLiveChannelDetails(channelId: channelId ?? widget.channelData.details.id).then((data) async {
      channelData = data;
      setState(() {});
      appStore.setLoading(false);
      return data;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: SnapHelperWidget(
          future: future,
          loadingWidget: Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
          errorBuilder: (p0) {
            return NoDataWidget(
              imageWidget: noDataImage(),
              title: p0,
              onRetry: () {
                getChannelData();
              },
              retryText: language!.refresh,
            ).center();
          },
          onSuccess: (data) {
            if (data == null)
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: language!.noContentFound,
                onRetry: () {
                  getChannelData();
                },
                retryText: language!.refresh,
              ).center();
            else
              return AnimatedScrollView(
                controller: controller,
                refreshIndicatorColor: colorPrimary,
                children: [
                  data.details.url.validate().isNotEmpty
                      ? SizedBox(
                          key: UniqueKey(),
                          height: appStore.hasInFullScreen ? context.height() : context.height() * 0.26,
                          width: context.width(),
                          child: VideoWidget(
                            videoURL: channelData.details.url,
                            watchedTime: '',
                            videoType: PostType.LIVE_TV,
                            videoURLType: channelData.details.streamType,
                            videoId: channelData.details.id,
                            thumbnailImage: channelData.details.image.validate(),
                            isTrailer: false,
                          ),
                        )
                      : Stack(
                          children: [
                            CachedImageWidget(
                              url: data.details.image.validate().isNotEmpty ? data.details.image.validate() : Assets.imagesIcDefaultLiveChannel,
                              height: context.height() * 0.25,
                              width:  context.width(),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              child: BackButton(),
                              left: 8,
                              top: 8,
                            )
                          ],
                        ),
                  Container(
                    padding: EdgeInsets.only(bottom: 60, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data.details.genre.isNotEmpty) 16.height,
                                if (data.details.genre.isNotEmpty) Text(data.details.genre.validate().join(" • "), style: secondaryTextStyle()),
                                if (data.details.genre.isNotEmpty) 8.height,
                                Text(data.details.title.validate(), style: boldTextStyle(size: 22)),
                              ],
                            ).expand(),
                            if (data.details.shareUrl.validate().isNotEmpty)
                              AppButton(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: boxDecorationDefault(
                                    boxShadow: [],
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.share, size: 16, color: context.iconColor),
                                ),
                                height: 24,
                                width: 24,
                                padding: EdgeInsets.zero,
                                shapeBorder: RoundedRectangleBorder(borderRadius: radius(24)),
                                onTap: () {
                                  shareMovieOrEpisode(data.details.shareUrl.validate());
                                },
                                color: context.cardColor,
                              )
                          ],
                        ),
                        if (data.details.description.validate().isNotEmpty) ...[
                          14.height,
                          ReadMoreText(
                            data.details.description.validate() + "",
                            style: secondaryTextStyle(),
                            trimLines: 4,
                            trimMode: TrimMode.Line,
                          ),
                        ],
                        if (data.recommendedChannels.validate().isNotEmpty) ...[
                          24.height,
                          Text('More Like This', style: primaryTextStyle()),
                          16.height,
                          AnimatedWrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            itemCount: data.recommendedChannels.validate().length,
                            itemBuilder: (p0, index) {
                              return CommonListItemComponent(
                                width: context.width() / 2 - 32,
                                isLandscape: true,
                                isLive: true,
                                onTap: () async {
                                  await getChannelData(
                                    channelId: data.recommendedChannels.validate()[index].id,
                                    showLoader: true,
                                  );
                                },
                                data: data.recommendedChannels.validate()[index],
                              );
                            },
                          )
                        ]
                      ],
                    ),
                  ).visible(!appStore.hasInFullScreen)
                ],
              );
          },
        ),
      ),
    );
  }
}

/* return AnimatedScrollView(
              controller: controller,
              children: [
                Column(
                  children: [
                    data.details.url.validate().isNotEmpty
                        ? SizedBox(
                            height: appStore.hasInFullScreen ? context.height() : context.height() * 0.36,
                            width: context.width(),
                            child: Stack(
                              children: [
                                _buildPlayerWidget(),
                                Positioned(
                                  child: LiveTagComponent(),
                                  left: 16,
                                  top: kToolbarHeight + 8,
                                )
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              CachedImageWidget(
                                url: data.details.image.validate(),
                                height: context.height() * 0.36,
                                width: context.width(),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                child: BackButton(),
                                left: 16,
                                top: kToolbarHeight,
                              )
                            ],
                          ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data.details.genre.isNotEmpty) Text(data.details.genre.validate().join(" • "), style: secondaryTextStyle()),
                                if (data.details.genre.isNotEmpty) 8.height,
                                Text(data.details.title.validate(), style: boldTextStyle(size: 22)),
                              ],
                            ).expand(),
                            if (data.details.shareUrl.validate().isNotEmpty)
                              AppButton(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: boxDecorationDefault(
                                    boxShadow: [],
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.share, size: 16, color: context.iconColor),
                                ),
                                height: 24,
                                width: 24,
                                padding: EdgeInsets.zero,
                                shapeBorder: RoundedRectangleBorder(borderRadius: radius(24)),
                                onTap: () {
                                  shareMovieOrEpisode(data.details.shareUrl.validate());
                                },
                                color: context.cardColor,
                              )
                          ],
                        ),
                        if (data.details.description.validate().isNotEmpty) 14.height,
                        if (data.details.description.validate().isNotEmpty)
                          ReadMoreText(
                            data.details.description.validate() + "",
                            style: secondaryTextStyle(),
                            trimLines: 4,
                            trimMode: TrimMode.Line,
                          )
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 16).visible(!appStore.hasInFullScreen)
                  ],
                ),
                if (data.recommendedChannels.validate().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('More Like This', style: primaryTextStyle()),
                      16.height,
                      AnimatedWrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        itemCount: data.recommendedChannels.validate().length,
                        itemBuilder: (p0, index) {
                          return CommonListItemComponent(
                            width: context.width() / 2 - 32,
                            isLandscape: true,
                            isLive: true,
                            onTap: () async {
                              await getChannelData(channelId: data.recommendedChannels.validate()[index].id);
                            },
                            data: data.recommendedChannels.validate()[index],
                          );
                        },
                      )
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 16).visible(!appStore.hasInFullScreen),
              ],
            );*/
