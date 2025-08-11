import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class DownloadVideoFromLinkWidget extends StatefulWidget
    with WidgetsBindingObserver {
  final String videoName;
  final String videoLink;
  final String videoId;
  final String videoImage;
  final String videoDescription;
  final String videoDuration;
  final VoidCallback? onDownloadStarted;
  final VoidCallback? onDownloadFinished;
  final bool isDownloading;

  const DownloadVideoFromLinkWidget({
    super.key,
    required this.videoName,
    required this.videoLink,
    required this.videoId,
    required this.videoImage,
    required this.videoDescription,
    required this.videoDuration,
    this.onDownloadStarted,
    this.onDownloadFinished,
    this.isDownloading = false,
  });

  @override
  _DownloadVideoFromLinkWidgetState createState() =>
      _DownloadVideoFromLinkWidgetState();
}

class _DownloadVideoFromLinkWidgetState
    extends State<DownloadVideoFromLinkWidget> {
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
    log('DownloadsController - _bindBackgroundIsolate called');
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    log('_bindBackgroundIsolate - isSuccess = $isSuccess');

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    } else {
      _port.listen((message) {
        setState(
              () {
            downloadTaskId = message[0];
            progress = message[2];
          },
        );

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
    log('DownloadsController - _unbindBackgroundIsolate called');
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, int status, int percent) {
    log("DownloadsController - registerCallback - task id = $id, status = $status, progress = $percent");

    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, percent]);
  }

  Future<void> downloadFile({required String url}) async {
    widget.onDownloadStarted?.call();
    log('DownloadsController - downloadFile - url = $url');
    if (isIOS) {
      await getApplicationDocumentsDirectory()
          .then((value) => downloadDirPath = value.path);
    } else {
      await getDownloadsDirectory()
          .then((value) => downloadDirPath = value!.path);
    }

    downloadTaskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: widget.videoName + '.mp4',
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
    print('FILE DOWNLOADED TO PATH: $downloadDirPath');

    data.id = widget.videoId.toInt();
    data.title = widget.videoName;
    data.image = widget.videoImage;
    data.description = widget.videoDescription;
    data.duration = widget.videoDuration;
    data.userId = getIntAsync(USER_ID);
    data.filePath = downloadDirPath + '/${widget.videoName}.mp4';
    data.isDeleted = false;
    data.inProgress = false;
    log(data.toJson());
    addOrRemoveFromLocalStorage(data);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      if (!isFileDownloaded && progress == null) {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: cardColor, borderRadius: radius(4)),
          child: CachedImageWidget(
              url: ic_download,
              color: textSecondaryColor,
              width: 22,
              height: 22),
        ).onTap(() async {
          if (!widget.isDownloading) {
            await downloadFile(url: widget.videoLink);
          }
        });
      } else if (progress != null && (!downloadedFailed)) {
        return Text(
          '$progress%',
          style: primaryTextStyle(size: 14, color: colorPrimary),
        );
      } else if (isFileDownloaded) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardColor, borderRadius: radius(4)),
          child: Icon(Icons.delete, color: textSecondaryColor, size: 20),
        ).onTap(() {
          addOrRemoveFromLocalStorage(data, isDelete: true);
          isFileDownloaded = false;
          progress = null;
          setState(() {});
        });
      } else if (downloadedFailed) {
        return IconButton(
          onPressed: () async {
            await downloadFile(url: widget.videoLink);
          },
          constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
          icon: Icon(Icons.refresh, color: colorPrimary),
          tooltip: language!.refresh,
        );
      } else {
        return Offstage();
      }
    });
  }
}
