import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:nb_utils/nb_utils.dart' as navigator show pop;
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/playlist/components/create_play_list_widget.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_item_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../../../utils/resources/colors.dart';

class PlaylistListWidget extends StatefulWidget {
  final String playlistType;
  final int postId;

  const PlaylistListWidget({Key? key, required this.playlistType, required this.postId}) : super(key: key);

  @override
  State<PlaylistListWidget> createState() => _PlaylistListWidgetState();
}

class _PlaylistListWidgetState extends State<PlaylistListWidget> {
  late Future<List<PlaylistModel>> _playlistFuture;
  PlaylistModel? playlistData;

  String noDataTitle = '';

  @override
  void initState() {
    _playlistFuture = getPlayListByType(type: widget.playlistType, postId: widget.postId);
    super.initState();

    if (widget.playlistType == playlistMovie) {
      noDataTitle = language!.movies;
    } else if (widget.playlistType == playlistTvShows) {
      noDataTitle = language!.tVShows;
    }else if (widget.playlistType == playlistEpisodes) {
      noDataTitle = language!.episodes;
    } else {
      noDataTitle = language!.videos;
    }
    setState(() {});
  }

  Future<void> createPlayList(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreatePlayListWidget(
          playlistType: widget.playlistType,
          onPlaylistCreated: () {
             PlayListItemWidgetState().onCreategrpup(widget.playlistType.toString());
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: context.height() * 0.8,
      decoration: boxDecorationDefault(color: search_edittext_color,borderRadius: radiusOnly(topLeft: defaultRadius+8,topRight: defaultRadius+8)),
      child: Observer(builder: (context) {
        return appStore.isLoading
            ? CircularProgressIndicator(strokeWidth: 2).center()
            : FutureBuilder<List<PlaylistModel>>(
                future: _playlistFuture,
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (snap.data.validate().isEmpty) {
                      return NoDataWidget(
                        imageWidget: noDataImage(),
                        title: '${language!.noPlaylistsFoundFor} $noDataTitle',
                        subTitle: '${language!.createPlaylistAndAdd} $noDataTitle',
                        onRetry: () {
                          finish(context);
                          createPlayList(context);
                        },
                        retryText: language!.createPlaylist,
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language!.addToPlaylist, style: boldTextStyle(size: 18)).paddingSymmetric(vertical: 8, horizontal: 16),
                          ListView.builder(
                            itemCount: snap.data.validate().length,
                            itemBuilder: (ctx, index) {
                              PlaylistModel _data = snap.data.validate()[index];

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.grey.withValues(alpha:0.1), borderRadius: radius()),
                                child: TextIcon(
                                  onTap: () {
                                    Map req = {
                                      "playlist_id": _data.playlistId,
                                      "post_id": widget.postId.validate(),
                                    };

                                    editPlaylistItems(request: req, type: widget.playlistType, playListId: _data.playlistId, isDelete:  _data.isInPlaylist).then((value) {
                                      setState(() {});
                                      toast(value.message);
                                      navigator.pop();
                                    }).catchError((e) {
                                      log("====>>>>Add to Playlist Error : ${e.toString()}");
                                      toast(language!.somethingWentWrong);
                                    });

                                    _data.isInPlaylist = !_data.isInPlaylist;
                                    setState(() {});
                                  },
                                  text: _data.playlistName,
                                  textStyle: primaryTextStyle(size: 18),
                                  spacing: 16,
                                  expandedText: true,
                                  suffix: Container(
                                    color: context.scaffoldBackgroundColor,
                                    padding: EdgeInsets.all(4),
                                    child: Icon(_data.isInPlaylist ? Icons.check : Icons.add, color: context.primaryColor, size: 20),
                                  ),
                                ),
                              );
                            },
                          ).expand(),
                        ],
                      );
                    }
                  } else if (snap.hasError) {
                    log("====>Movie Detail Playlist Error : ${snap.error.toString()}");
                    return Text(language!.somethingWentWrong, style: primaryTextStyle(size: 22)).center();
                  }
                  return CircularProgressIndicator(strokeWidth: 2).center().paddingAll(16);
                },
              );
      }),
    );
  }
}
