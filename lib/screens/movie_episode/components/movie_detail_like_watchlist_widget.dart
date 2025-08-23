import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_list_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/models/download_data.dart';

// ignore: must_be_immutable
class MovieDetailLikeWatchListWidget extends StatefulWidget {
  static String tag = '/LikeWatchlistWidget';

  final VoidCallback? onAction;
  final int postId;
  bool? isInWatchList;
  bool? isLiked;
  int? likes;
  final PostType postType;
  final String? videoName;
  final String? videoLink;
  final String? videoImage;
  final String? videoDescription;
  final String? videoDuration;
  final bool? userHasAccess;
  final bool? isTrailerVideoPlaying;
  final VoidCallback? onDownloadStarted;
  final VoidCallback? onDownloadFinished;

  MovieDetailLikeWatchListWidget({
    this.onAction,
    required this.postId,
    this.isInWatchList,
    this.isLiked,
    this.likes,
    required this.postType,
    this.videoName,
    this.videoLink,
    this.videoImage,
    this.videoDescription,
    this.videoDuration,
    this.userHasAccess,
    this.isTrailerVideoPlaying,
    this.onDownloadStarted,
    this.onDownloadFinished,
  });

  @override
  MovieDetailLikeWatchListWidgetState createState() =>
      MovieDetailLikeWatchListWidgetState();
}

class MovieDetailLikeWatchListWidgetState
    extends State<MovieDetailLikeWatchListWidget> with WidgetsBindingObserver {
  late String downloadDirPath;
  final ReceivePort _port = ReceivePort();
  String? downloadTaskId;
  bool isFileDownloaded = false;
  bool downloadedFailed = false;
  DownloadData data = DownloadData(postType: null);
  int? progress;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    init();
  }

  Future<void> init() async {
    List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty
        ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List)
            .map((e) => DownloadData.fromJson(e))
            .toList()
        : [];

    if (list.isNotEmpty) {
      for (var i in list) {
        if (i.title == widget.videoName) {
          checkIfFileExists().then((value) {
            isFileDownloaded = true;
            data = i;
            setState(() {});
          });
          break;
        }
      }
    }

    setState(() {});
  }

  _bindBackgroundIsolate() async {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    } else {
      _port.listen((message) {
        setState(() {
          downloadTaskId = message[0];
          progress = message[2];
        });

        if (message[1] == 3) {
          onDownloadComplete();
        }
      });
      await FlutterDownloader.registerCallback(downloadCallback);
    }
  }

  Future<bool> checkIfFileExists() async {
    final savedDir = await getDownloadsDirectory();
    final file = File('${savedDir!.path}/${widget.videoName}.mp4');
    return await file.exists();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, int status, int percent) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, percent]);
  }

  Future<void> downloadFile({required String url}) async {
    widget.onDownloadStarted?.call();
    if (isIOS) {
      await getApplicationDocumentsDirectory()
          .then((value) => downloadDirPath = value.path);
    } else {
      await getDownloadsDirectory()
          .then((value) => downloadDirPath = value!.path);
    }

    downloadTaskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: '${widget.videoName}.mp4',
      savedDir: downloadDirPath,
      showNotification: true,
      openFileFromNotification: true,
      headers: {},
    );
    widget.onDownloadFinished?.call();
  }

  void onDownloadComplete() {
    isFileDownloaded = true;
    progress = null;
    setState(() {});
    data.id = widget.postId.toInt();
    data.title = widget.videoName;
    data.image = widget.videoImage;
    data.description = widget.videoDescription;
    data.duration = widget.videoDuration;
    data.userId = getIntAsync(USER_ID);
    data.filePath = downloadDirPath + '/${widget.videoName}.mp4';
    data.isDeleted = false;
    data.inProgress = false;
    addOrRemoveFromLocalStorage(data);
  }

  Future<void> watchlistClick() async {
    if (!mIsLoggedIn) {
      SignInScreen().launch(context);
      return;
    }
    Map req = {
      'post_id': widget.postId.validate(),
      'user_id': getIntAsync(USER_ID),
      'post_type': widget.postType == PostType.MOVIE
          ? 'movie'
          : widget.postType == PostType.TV_SHOW
              ? 'tv_show'
              : 'video',
      'action': widget.isInWatchList.validate() ? 'remove' : 'add',
    };

    widget.isInWatchList = !widget.isInWatchList.validate();
    setState(() {});

    await watchlistMovie(req).then((value) {
      toast(value.isAdded!
          ? language.movieAddedToYourWatchlist
          : language.movieRemovedFromYourWatchlist);
      //
    }).catchError((e) {
      widget.isInWatchList = !widget.isInWatchList.validate();
      toast(e.toString());

      setState(() {});
    });
  }

  Future<void> likeClick() async {
    if (!mIsLoggedIn) {
      SignInScreen().launch(context);
      return;
    }

    Map req = {
      'post_id': widget.postId.validate(),
      'post_type': widget.postType == PostType.MOVIE
          ? 'movie'
          : widget.postType == PostType.TV_SHOW
              ? 'tv_show'
              : 'video',
    };
    widget.isLiked = !widget.isLiked.validate();

    if (widget.isLiked.validate()) {
      widget.likes = widget.likes.validate() + 1;
    } else {
      widget.likes = widget.likes.validate() - 1;
    }
    setState(() {});

    await likeMovie(req).then((res) {}).catchError((e) {
      widget.isLiked = !widget.isLiked.validate();
      if (widget.isLiked.validate()) {
        widget.likes = widget.likes! + 1;
      } else {
        widget.likes = widget.likes! - 1;
      }
      toast(e.toString());

      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800),
                    shape: BoxShape.circle),
                child: IconButton(
                  onPressed: likeClick,
                  icon: Icon(
                      widget.isLiked.validate()
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: textColorSecondary),
                ),
              ),
              8.width,
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800),
                    shape: BoxShape.circle),
                child: IconButton(
                  onPressed: watchlistClick,
                  icon: Icon(
                      widget.isInWatchList.validate()
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: textColorSecondary),
                ),
              ),
              8.width,
              if (widget.postType != PostType.TV_SHOW)
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade800),
                      shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () {
                      if (appStore.isLogging) {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: radiusCircular(defaultRadius + 8),
                                  topLeft: radiusCircular(defaultRadius + 8))),
                          builder: (dialogContext) {
                            return PlaylistListWidget(
                              playlistType: widget.postType == PostType.MOVIE
                                  ? playlistMovie
                                  : widget.postType == PostType.TV_SHOW
                                      ? playlistTvShows
                                      : playlistVideo,
                              postId: widget.postId.validate(),
                            );
                          },
                        );
                      } else {
                        SignInScreen().launch(context);
                      }
                    },
                    icon: Icon(Icons.library_add_outlined,
                        color: textColorSecondary),
                  ),
                ),
              8.width,
              if (widget.videoLink.validate().isNotEmpty &&
                  appStore.isLogging &&
                  widget.userHasAccess.validate() &&
                  !widget.isTrailerVideoPlaying.validate())
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade800),
                      shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () async {
                      if (!isFileDownloaded && progress == null) {
                        await downloadFile(url: widget.videoLink.validate());
                      } else if (isFileDownloaded) {
                        addOrRemoveFromLocalStorage(data, isDelete: true);
                        isFileDownloaded = false;
                        progress = null;
                        setState(() {});
                      } else if (downloadedFailed) {
                        await downloadFile(url: widget.videoLink.validate());
                      }
                    },
                    icon: Icon(
                        isFileDownloaded
                            ? Icons.delete
                            : progress != null
                                ? Icons.downloading
                                : downloadedFailed
                                    ? Icons.refresh
                                    : Icons.download_outlined,
                        color: textColorSecondary),
                  ),
                ),
            ],
          ),
        ),
        6.height,
        Text('♡ ${buildLikeCountText(widget.likes.validate())}',
                style: secondaryTextStyle())
            .paddingSymmetric(horizontal: 8),
      ],
    );
  }
}
