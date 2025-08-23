import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';

enum UpcomingList { UPCOMING_MOVIE, RELATED, UPCOMING_VIDEO }

class UpcomingRelatedMovieListWidget extends StatefulWidget {
  final MovieDetailResponse? snap;

  UpcomingRelatedMovieListWidget({this.snap});

  @override
  State<UpcomingRelatedMovieListWidget> createState() => _UpcomingRelatedMovieListWidgetState();
}

class _UpcomingRelatedMovieListWidgetState extends State<UpcomingRelatedMovieListWidget> {
  UpcomingList? selected;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    if (widget.snap!.recommendedMovie.validate().isNotEmpty) {
      selected = UpcomingList.RELATED;
    } else if (widget.snap!.upcomingMovie.validate().isNotEmpty) {
      selected = UpcomingList.UPCOMING_MOVIE;
    } else if (widget.snap!.upcomingVideo.validate().isNotEmpty) {
      selected = UpcomingList.UPCOMING_VIDEO;
    } else {
      //
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (selected != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.snap!.recommendedMovie.validate().isNotEmpty)
                TextButton(
                  onPressed: () {
                    selected = UpcomingList.RELATED;
                    setState(() {});
                  },
                  child: Text(
                    language.recommendedMovies,
                    style: secondaryTextStyle(
                      size: 16,
                      color: selected == UpcomingList.RELATED ? context.primaryColor : textSecondaryColorGlobal,
                    ),
                  ),
                ),
              if (widget.snap!.recommendedMovie.validate().isNotEmpty)
                TextButton(
                  onPressed: () {
                    selected = UpcomingList.UPCOMING_MOVIE;
                    setState(() {});
                  },
                  child: Text(
                    language.upcomingMovies,
                    style: secondaryTextStyle(
                      size: 16,
                      color: selected == UpcomingList.UPCOMING_MOVIE ? context.primaryColor : textSecondaryColorGlobal,
                    ),
                  ),
                ),
              if (widget.snap!.upcomingVideo.validate().isNotEmpty)
                TextButton(
                  onPressed: () {
                    selected = UpcomingList.UPCOMING_VIDEO;
                    setState(() {});
                  },
                  child: Text(
                    language.upcomingVideo,
                    style: secondaryTextStyle(
                      size: 16,
                      color: selected == UpcomingList.UPCOMING_VIDEO ? context.primaryColor : textSecondaryColorGlobal,
                    ),
                  ),
                ),
            ],
          ).paddingAll(16),
          if (selected == UpcomingList.RELATED)
            ItemHorizontalList(widget.snap!.recommendedMovie!)
          else if (selected == UpcomingList.UPCOMING_MOVIE)
            ItemHorizontalList(widget.snap!.upcomingMovie!)
          else if (selected == UpcomingList.UPCOMING_VIDEO)
            ItemHorizontalList(widget.snap!.upcomingVideo!),
        ],
      );
    } else {
      return Offstage();
    }
  }
}
