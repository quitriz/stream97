import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class EpisodeItemComponent extends StatelessWidget {
  final MovieData episode;
  final VoidCallback? callback;

  const EpisodeItemComponent({required this.episode, this.callback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callback?.call();
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          CachedImageWidget(
            url: episode.image.validate().isEmpty ? default_image : episode.image.validate(),
            width: 140,
            height: 70,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(radius_container),
          16.width,
          Column(
            children: [
              Marquee(child: Text(
                episode.title.validate(),
                style: boldTextStyle(size: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),),
              Marquee(child: Text(
                episode.runTime.validate() + ' • ' + episode.releaseDate.validate(),
                style: secondaryTextStyle(size: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),)


            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ).expand(),
        ],
      ),
    ).paddingSymmetric(vertical: 4, horizontal: 22);
  }
}
