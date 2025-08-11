import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';

class DashboardSliderWidget extends StatefulWidget {
  final List<CommonDataListModel> mSliderList;

  DashboardSliderWidget({required this.mSliderList, super.key});

  @override
  State<DashboardSliderWidget> createState() => _DashboardSliderWidgetState();
}

class _DashboardSliderWidgetState extends State<DashboardSliderWidget> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = context.width();
    final Size cardSize = Size(width, appStore.hasInFullScreen ? context.height() : context.height() * 0.26);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: cardSize.height,
          width: cardSize.width,
          decoration: BoxDecoration(boxShadow: [], color: context.scaffoldBackgroundColor),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: widget.mSliderList.validate().length,
            itemBuilder: (context, index) {
              CommonDataListModel slider = widget.mSliderList.validate()[index];
              return Container(
                key: UniqueKey(),
                width: context.width(),
                height: cardSize.height,
                decoration: BoxDecoration(boxShadow: [], color: context.scaffoldBackgroundColor),
                child: VideoWidget(
                  videoURL: slider.trailerLink.validate(),
                  watchedTime: '',
                  videoType: slider.postType,
                  videoURLType: slider.trailerLinkType.validate(),
                  videoId: slider.id.validate(),
                  thumbnailImage: slider.image.validate(),
                  isTrailer: true,
                  isSlider: true,
                  onTap: () async {
                    appStore.setTrailerVideoPlayer(true);
                    await MovieDetailScreen(movieData: slider).launch(context).then((value) {
                      setState(() {});
                    });
                  },
                ),
              );
            },
          ),
        ),
        8.height,
        if(widget.mSliderList.validate().length > 1)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.mSliderList.validate().length, (index) {
            bool isActive = _currentPage == index;
            return AnimatedContainer(
              duration: 300.milliseconds,
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 16 : 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.grey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
