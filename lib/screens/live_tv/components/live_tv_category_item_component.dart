import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart' show LiveTagComponent;
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import '../../../models/live_tv/live_category_list_model.dart';

///Category item component for Live TV categories
class LiveTvCategoryItemComponent extends StatelessWidget {
  final Data category;
  final VoidCallback? onTap;

  const LiveTvCategoryItemComponent({Key? key, required this.category, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cat = category;
    return Container(
      width: 150,
      height: 90,
      decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cat.thumbnailImage != null && cat.thumbnailImage!.isNotEmpty
              ? CachedImageWidget(url: cat.thumbnailImage!, height: 48, width: 48)
              : CachedImageWidget(url: default_image, height: 48, width: 48),
          8.height,
          Text(cat.name ?? '', style: boldTextStyle(color: Colors.white, size: 16), textAlign: TextAlign.center),
        ],
      ),
    ).onTap(onTap);
  }
}

///Category item component for Live TV channels
class LiveChannelCardItemComponent extends StatelessWidget {
  final CategoryData channel;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const LiveChannelCardItemComponent({Key? key, required this.channel, this.onTap, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: context.primaryColor.withAlpha(77),
      highlightColor: context.primaryColor.withAlpha(25),
      onTap: onTap ??
          () async {
            if (channel.id != null) {
              try {
                await ChannelDetailScreen(channelId: channel.id!).launch(context);
              } catch (e) {
                log('Error navigating to channel detail: $e');
              }
            } else {
              log('Channel ID not available');
            }
          },
      child: Stack(
        children: [
          Container(
            width: width ?? (context.width() / 2 - 22),
            height: height ?? (context.height() * .12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  channel.thumbnailImage != null && channel.thumbnailImage!.isNotEmpty
                      ? CachedImageWidget(url: channel.thumbnailImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                      : CachedImageWidget(url: default_image, height: double.infinity, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withAlpha(230), Colors.black.withAlpha(128), Colors.transparent],
                          stops: [0.0, 0.7, 1.0],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: LiveTagComponent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
