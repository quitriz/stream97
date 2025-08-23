import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import '../live_tv/screens/channel_detail_screen.dart';

class GenreMovieListScreen extends StatefulWidget {
  static String tag = '/GenreMovieListScreen';
  final String? genre;
  final String? type;
  final String slug;

  GenreMovieListScreen({this.genre, this.type, required this.slug});

  @override
  GenreMovieListScreenState createState() => GenreMovieListScreenState();
}

class GenreMovieListScreenState extends State<GenreMovieListScreen> {
  ScrollController scrollController = ScrollController();
  List<CommonDataListModel> genreMovieList = [];

  bool loadMore = true;
  bool hasError = false;

  int page = 1;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
    scrollController.addListener(
      () {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (loadMore) {
            page++;
            appStore.setLoading(true);
            setState(() {});

            init();
          }
        }
      },
    );
  }

  Future<void> init() async {
    if (await isNetworkAvailable()) {
      appStore.setLoading(true);
      await getMovieListByGenre(widget.slug, widget.type!, page).then((value) {
        appStore.setLoading(false);

        if (page == 1) genreMovieList.clear();
        loadMore = value.length == postPerPage;

        genreMovieList.addAll(value);

        setState(() {});
      }).catchError((error) {
        appStore.setLoading(false);
        hasError = true;
        setState(() {});

        log(error.toString());
      });
    } else {
      hasError = true;
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          parseHtmlString(widget.genre!.validate().capitalizeFirstLetter()),
          style: boldTextStyle(),
        ),
        backgroundColor: context.scaffoldBackgroundColor,
        centerTitle: false,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Observer(builder: (context) {
        return Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: genreMovieList.map((e) {
                    return CommonListItemComponent(
                      data: e,
                      isVerticalList: widget.type != dashboardTypeLive,
                      isLandscape: widget.type == dashboardTypeLive,
                      isLive: widget.type == dashboardTypeLive,
                      onTap: widget.type == dashboardTypeLive
                          ? () {
                              ChannelDetailScreen(channelId: e.id.validate()).launch(context);
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noContentFound,
                subTitle: language.theContentHasNot,
              ).center().visible(!appStore.isLoading && genreMovieList.isEmpty && !hasError),
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noContentFound,
                subTitle: language.somethingWentWrong,
              ).center().visible(!appStore.isLoading && genreMovieList.isEmpty && hasError),
              Observer(
                builder: (context) => LoaderWidget().visible(appStore.isLoading),
              ),
            ],
          ),
        );
      }),
    );
  }
}
