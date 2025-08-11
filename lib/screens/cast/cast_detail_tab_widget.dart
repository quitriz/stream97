import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

// ignore: must_be_immutable
class CastDetailTabWidget extends StatefulWidget {
  static String tag = '/CastDetailTabWidget';
  final int? castId;
  final String? type;

  CastDetailTabWidget({this.castId, this.type});

  @override
  CastDetailTabWidgetState createState() => CastDetailTabWidgetState();
}

class CastDetailTabWidgetState extends State<CastDetailTabWidget> {
  ScrollController _controller = ScrollController();
  List<CommonDataListModel> _list = [];

  int page = 1;
  bool loadMore = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();

    _controller
      ..addListener(() {
        if (_controller.position.pixels == _controller.position.maxScrollExtent) {
          if (loadMore) {
            page++;
            isLoading = true;

            init();
            setState(() {});
          }
        }
      });
  }

  Future<void> init() async {
    AsyncMemoizer<List<CommonDataListModel>>().runOnce(() => getCastMovieTvShowList(page: page, castId: widget.castId, type: widget.type)).then((value) {
      loadMore = value.length == postPerPage;
      if (page == 1) _list.clear();
      _list.addAll(value);

      isLoading = false;

      setState(() {});
    }).catchError((error) {
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (context, index) {
            CommonDataListModel data = _list[index];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CachedImageWidget(
                  url: data.image.validate(),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ).cornerRadiusWithClipRRect(defaultRadius),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(data.title.validate(), style: boldTextStyle(size: 18)),
                    4.height,
                    if (data.characterName.validate().isNotEmpty)
                      Text(
                        '${language!.as} ${data.characterName.validate()}',
                        style: secondaryTextStyle(color: Colors.grey.shade500),
                      ).paddingBottom(4),
                    Text(data.releaseYear.validate(), style: secondaryTextStyle(color: Colors.grey.shade500)),
                  ],
                ).paddingSymmetric(horizontal: 12).expand()
              ],
            ).onTap(() {
              finish(context);
              appStore.setTrailerVideoPlayer(true);
              MovieDetailScreen(movieData: data).launch(context);
            }, borderRadius: BorderRadius.circular(defaultRadius)).paddingAll(8);
          },
        ),
        NoDataWidget(
          imageWidget: noDataImage(),
          title: language!.noContentFound,
          subTitle: language!.theContentHasNot,
        ).center().visible(_list.isEmpty && !isLoading),
        LoaderWidget().visible(isLoading),
      ],
    );
  }
}
