import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/episode_item_component.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/episode_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../../../utils/resources/colors.dart';

class SeasonDataWidget extends StatefulWidget {
  final MovieSeason? movieSeason;
  final int postId;
  final ScrollController scrollController;
  final CommonModelMovieDetail dropdownValue;
  final bool hasUserAccess;

  SeasonDataWidget({
    this.movieSeason,
    required this.postId,
    required this.scrollController,
    required this.dropdownValue,
    required this.hasUserAccess,
  });

  @override
  SeasonDataWidgetState createState() => SeasonDataWidgetState();
}

class SeasonDataWidgetState extends State<SeasonDataWidget> {
  int mPage = 1;
  bool mIsLastPage = false;
  bool isLoading = false;
  bool isError = false;

  CommonModelMovieDetail? dropdownValue;
  List<MovieData> episodes = [];

  @override
  void initState() {
    super.initState();

    dropdownValue = widget.dropdownValue;

    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
              widget.scrollController.position.maxScrollExtent &&
          !mIsLastPage &&
          !isLoading) {
        mPage++;
        getSeasonDetails();
      }
    });

    getSeasonDetails();
  }

  Future<void> getSeasonDetails() async {
    setState(() {
      isError = false;
      isLoading = true;
    });

    await tvShowSeasonDetail(
      showId: widget.postId.validate(),
      seasonId: dropdownValue!.id.validate().toInt(),
      page: mPage,
    ).then((value) {
      mIsLastPage = value.episodes.validate().length != postPerPage;
      episodes.addAll(value.episodes.validate());
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      log(e.toString());
      setState(() {
        isError = true;
        isLoading = false;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.movieSeason!.data.validate().length > 1
            ? DropdownButtonHideUnderline(
                child: DropdownButton<CommonModelMovieDetail>(
                  padding: EdgeInsets.zero,
                  dropdownColor: search_edittext_color,
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down),
                  borderRadius: BorderRadius.circular(defaultRadius),
                  elevation: 0,
                  style: primaryTextStyle(),
                  onChanged: (CommonModelMovieDetail? newValue) async {
                    if (newValue != null && dropdownValue != newValue) {
                      episodes.clear();
                      setState(() {
                        mPage = 1;
                        dropdownValue = newValue;
                        isLoading = true;
                      });
                      await getSeasonDetails();
                    }
                  },
                  items: widget.movieSeason!.data
                      .validate()
                      .map<DropdownMenuItem<CommonModelMovieDetail>>((season) {
                    return DropdownMenuItem(
                      value: season,
                      child: Text(season.name.validate(),
                          style: primaryTextStyle()),
                    );
                  }).toList(),
                ).paddingOnly(left: 16),
              )
            : Text(
                    widget.movieSeason!.data
                        .validate()[0]
                        .name
                        .validate()
                        .capitalizeFirstLetter(),
                    style: primaryTextStyle())
                .paddingOnly(left: 16),
        16.height,
        if (!isError && episodes.validate().isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: episodes.validate().length,
            itemBuilder: (_, index) {
              MovieData episode = episodes.validate()[index];
              return EpisodeItemComponent(
                episode: episode,
                callback: () {
                  LiveStream().emit(PauseVideo);

                  if (widget.hasUserAccess) {
                    finish(context);
                    EpisodeDetailScreen(
                      title: episode.title.validate(),
                      episode: episode,
                      episodes: episodes,
                      index: index,
                      lastIndex: episodes.validate().length,
                      tvShowUserHasAccess: widget.hasUserAccess,
                    ).launch(context);
                  } else {
                    toast(language.youDontHaveMembership);
                  }
                },
              );
            },
          )
        else if (episodes.validate().isEmpty && !isLoading)
          NoDataWidget(
            imageWidget: noDataImage(),
            title: language.notFound,
          )
        else if (isError)
          NoDataWidget(
            imageWidget: noDataImage(),
            title: language.somethingWentWrong,
          ),
        LoadingDotsWidget().visible(isLoading),
      ],
    );
  }
}
