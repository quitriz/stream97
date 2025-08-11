import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class PlaylistMediaScreen extends StatefulWidget {
  final int playlistId;
  final String playlistTitle;
  final String playlistType;

  const PlaylistMediaScreen({
    Key? key,
    required this.playlistId,
    required this.playlistTitle,
    required this.playlistType,
  }) : super(key: key);

  @override
  State<PlaylistMediaScreen> createState() => _PlaylistMediaScreenState();
}

class _PlaylistMediaScreenState extends State<PlaylistMediaScreen> {
  List<CommonDataListModel> playlistMediaList = [];

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    isError = false;
    setState(() {});
    appStore.setLoading(true);
    await getPlayListMedia(playlistId: widget.playlistId, postType: widget.playlistType, page: mPage).then((value) {
      if (mPage == 1) playlistMediaList.clear();
      mIsLastPage = value.length != 7;

      playlistMediaList.addAll(value);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      log("Error Log ===== $e");
      toast(language!.somethingWentWrong);
      log("====>>>>>Playlist Media Error : ${e.toString()}");
    });
  }

  Future<void> deleteMovieFromPlaylist({required CommonDataListModel movieData, required int playlistId, required int postId, required String postType}) async {
    Map req = {
      "playlist_id": playlistId,
      "post_id": postId,
    };
    appStore.setLoading(true);
    editPlaylistItems(request: req, type: widget.playlistType, playListId: playlistId, isDelete: true).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      playlistMediaList.remove(movieData);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      log("====>>>>Delete From Playlist Error : ${e.toString()}");
      toast(language!.somethingWentWrong);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.playlistTitle, style: boldTextStyle(size: 22)),
      ),
      body: Stack(
        children: [
          AnimatedListView(
            itemCount: playlistMediaList.length,
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 50, top: 8),
            itemBuilder: (_, index) {
              CommonDataListModel _data = playlistMediaList[index];
              return GestureDetector(
                onTap: () {
                  MovieDetailScreen(
                    movieData: _data,
                    playList: playlistMediaList,
                    currentIndex: index,
                    onRemoveFromPlaylist: () {
                      init();
                    },
                  ).launch(context);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Color(0xFF484848), blurRadius: 2.0)],
                    color: context.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedImageWidget(url: _data.image.validate(), height: 80, width: 70, fit: BoxFit.fill).cornerRadiusWithClipRRect(8),
                      8.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _data.title.validate(),
                            style: primaryTextStyle(size: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.height,
                          Text(
                            _data.runTime.validate(),
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ).expand(),
                      8.width,
                      IconButton(
                        onPressed: () {
                          deleteMovieFromPlaylist(
                            movieData: _data,
                            postType: _data.postType == PostType.MOVIE
                                ? playlistMovie
                                : _data.postType == PostType.TV_SHOW
                                    ? playlistTvShows
                                    : playlistVideo,
                            playlistId: widget.playlistId,
                            postId: _data.id.validate(),
                          );
                        },
                        color: colorPrimary,
                        icon: Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
            onNextPage: () {
              if (!mIsLastPage) {
                mPage++;
                init();
              }
            },
          ),
          Observer(
            builder: (_) {
              if (!appStore.isLoading && playlistMediaList.isEmpty) {
                if (isError) {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: language!.somethingWentWrong,
                  ).center();
                } else {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: '${widget.playlistTitle} ${language!.isEmpty}',
                    subTitle: '${language!.contentAddedTo} ${widget.playlistTitle}, ${language!.willBeShownHere}',
                  );
                }
              } else {
                return Offstage();
              }
            },
          ),
          Observer(
            builder: (_) {
              if (mPage == 1) {
                return LoaderWidget().center().visible(appStore.isLoading);
              } else {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: LoadingDotsWidget(),
                ).visible(appStore.isLoading);
              }
            },
          ),
        ],
      ),
    );
  }
}
