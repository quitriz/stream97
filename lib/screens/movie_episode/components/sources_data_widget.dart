import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/sources.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class SourcesDataWidget extends StatelessWidget {
  final List<Sources>? sourceList;
  final Function(Sources)? onLinkTap;

  SourcesDataWidget({this.sourceList, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.quality, style: boldTextStyle(color: colorPrimary)),
              Text(language.language, style: boldTextStyle(color: colorPrimary)),
              Text(language.date, style: boldTextStyle(color: colorPrimary)),
              Text(language.links, style: boldTextStyle(color: colorPrimary)),
            ],
          ),
          Divider(color: Colors.white54),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
            itemCount: sourceList!.length,
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(sourceList![index].quality.validate(), style: primaryTextStyle(), overflow: TextOverflow.ellipsis)),
                  Flexible(child: Text(sourceList![index].language.validate(), style: primaryTextStyle(), maxLines: 3, overflow: TextOverflow.ellipsis)),
                  Flexible(
                    child: Marquee(
                      child: Text(sourceList![index].dateAdded.validate(), style: primaryTextStyle(size: 14), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Icon(LineIcons.alternate_external_link, size: 20, color: colorPrimary).onTap(
                        () async {
                      if (sourceList![index].isAffiliate ?? false) {
                        appLaunchUrl(sourceList![index].link.validate());
                      } else {
                        onLinkTap?.call(sourceList![index]);
                      }
                    },
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => Divider(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
