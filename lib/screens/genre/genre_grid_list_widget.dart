import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/screens/genre/genre_movie_list_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

// ignore: must_be_immutable
class GenreGridListWidget extends StatelessWidget {
  List<GenreData> list = [];
  String type;

  GenreGridListWidget(this.list, this.type);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 16,
      spacing: 16,
      children: list.map(
        (e) {
          GenreData data = list[list.indexOf(e)];

          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              GenreMovieListScreen(
                genre: data.name,
                type: type,
                slug: data.slug.validate(),
              ).launch(context);
            },
            child: Container(
              width: context.width() / 2 - 24,
              height: context.height() * 0.10,
              child: Stack(
                children: [
                  CachedImageWidget(
                    url: data.genreImage.validate(),
                    fit: BoxFit.cover,
                    width: context.width(),
                    height: context.height(),
                  ).cornerRadiusWithClipRRectOnly(bottomLeft: defaultRadius.toInt(), bottomRight: defaultRadius.toInt()),
                  Container(
                    width: context.width(),
                    height: context.height(),
                    padding: EdgeInsets.only(top: 18, bottom: 8),
                    decoration: BoxDecoration(borderRadius: radiusOnly(bottomLeft: defaultRadius, bottomRight: defaultRadius), color: Colors.black.withValues(alpha:0.5)),
                    child: Text(
                      '${parseHtmlString(data.name.validate())}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 5.0)],
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ).center(),
                  ),
                ],
              ).cornerRadiusWithClipRRect(radius_container),
            ),
          );
        },
      ).toList(),
    ).paddingAll(16);
  }
}
