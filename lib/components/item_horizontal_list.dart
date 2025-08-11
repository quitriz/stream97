import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';

import '../network/rest_apis.dart';
import '../utils/resources/colors.dart';

// ignore: must_be_immutable
class ItemHorizontalList extends StatelessWidget {
  List<CommonDataListModel> list = [];
  EdgeInsets? padding;
  bool isContinueWatch;
  bool isLandscape;
  final VoidCallback? refreshContinueWatchList;
  final bool isTop10;
  final bool isLiveTv;

  ItemHorizontalList(
    this.list, {
    this.isContinueWatch = false,
    this.refreshContinueWatchList,
    this.padding,
    this.isTop10 = false,
    this.isLandscape = false,
    this.isLiveTv = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      alignment: Alignment.centerLeft,
      child: HorizontalList(
        itemCount: list.length,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          CommonDataListModel data = list[index];
          return Stack(
            children: [
              CommonListItemComponent(
                data: data,
                isLandscape: isLandscape,
                isContinueWatch: isContinueWatch,
                isLive: isLiveTv,
                onTap: isLiveTv
                    ? () {
                        ChannelDetailScreen(channelId: data.id.validate()).launch(context);
                      }
                    : null,
                callback: () async {
                  await showConfirmDialogCustom(context,
                      primaryColor: colorPrimary,
                      cancelable: false,
                      onCancel: (c) {
                        finish(c);
                      },
                      title: language!.areYouSureYouWantToDeleteThisFromYourContinueWatching,
                      onAccept: (_) async {
                        finish(context);
                        await deleteVideoContinueWatch(postId: data.id.validate(), postType: data.postType).then((v) {
                          refreshContinueWatchList?.call();
                        }).catchError(onError);
                      });
                },
              ),
              if (isTop10.validate())
                Positioned(
                  bottom: -9,
                  right: 4,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}