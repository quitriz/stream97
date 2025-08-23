import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import '../main.dart';
import '../screens/live_tv/screens/channel_detail_screen.dart';

class LiveTvSliderComponent extends StatefulWidget {
  final CommonDataListModel sliderData;

  const LiveTvSliderComponent({Key? key, required this.sliderData}) : super(key: key);

  @override
  State<LiveTvSliderComponent> createState() => _LiveTvSliderComponentState();
}

class _LiveTvSliderComponentState extends State<LiveTvSliderComponent> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedImageWidget(
          url: widget.sliderData.image.validate(),
          height: context.height() * 0.28,
          width: context.width(),
          fit: BoxFit.contain,
        ),
        IgnorePointer(
          ignoring: true,
          child: Container(
            height: context.height() * 0.40,
            width: context.width(),
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  black.withValues(alpha: 0.8),
                  black.withValues(alpha: 0.5),
                  black.withValues(alpha: 0.9),
                  black.withValues(alpha: 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(widget.sliderData.title.validate(), style: boldTextStyle(size: 22)),
              8.height,
              AppButton(
                width: context.width() / 2,
                padding: EdgeInsets.zero,
                color: colorPrimary,
                onTap: () {
                  log(widget.sliderData.toJson());
                  if (appStore.isLogging) {
                    ChannelDetailScreen(channelId: widget.sliderData.id.validate()).launch(context);
                  } else {
                    SignInScreen(
                      redirectTo: () {
                        setState(() {});
                      },
                    ).launch(context);
                  }
                },
                child: Wrap(
                  spacing: 6,
                  children: [
                    Text(language.streamNow, style: primaryTextStyle()),
                    Icon(Icons.play_arrow, color: Colors.white),
                  ],
                ),
              ),
              16.height,
            ],
          ).paddingOnly(bottom: 28),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: LiveTagComponent(),
        )
      ],
    );
  }
}