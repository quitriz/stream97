import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/episode_detail_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class SearchCardComponent extends StatelessWidget {
  final List<CommonDataListModel> list;

  SearchCardComponent({required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: list.map((e) {
        return InkWell(
          onTap: () async {
            LiveStream().emit(PauseVideo);

            appStore.setTrailerVideoPlayer(true);
            finish(context);

            if (e.postType == PostType.EPISODE) {
              MovieData episode = MovieData();
              episode.title = e.title;
              episode.image = e.image;
              episode.id = e.id;
              episode.postType = PostType.EPISODE;

              await EpisodeDetailScreen(episode: episode, episodes: []).launch(context);
            } else {
              await MovieDetailScreen(movieData: e).launch(context);
            }
          },
          child: Row(
            children: [
              CachedImageWidget(
                url: e.image.validate(),
                width: 145,
                height: 90,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(radius_container),
              16.width,
              Column(
                children: [
                  Text(e.title.validate(), style: boldTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 1),
                  Text(e.runTime.validate(), style: secondaryTextStyle()),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ).expand(),
            ],
          ).paddingAll(16),
        );
      }).toList(),
    );
  }
}