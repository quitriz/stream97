import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/html_widget.dart';

import '../../utils/constants.dart';

class LocalMediaPlayerScreen extends StatefulWidget {
  final DownloadData data;

  const LocalMediaPlayerScreen({required this.data});

  @override
  State<LocalMediaPlayerScreen> createState() => _LocalMediaPlayerScreenState();
}

class _LocalMediaPlayerScreenState extends State<LocalMediaPlayerScreen> {
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    //
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Observer(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: context.width(),
                height: appStore.hasInFullScreen ? context.height() : context.height() * 0.3,
                child: VideoWidget(
                  videoId: widget.data.id.validate(),
                  videoURL: widget.data.filePath.validate(),
                  thumbnailImage: widget.data.image.validate(),
                  videoURLType: VideoType.typeFile,
                  isTrailer: false,
                  videoType: PostType.NONE,
                  watchedTime: '',
                ),
              ).paddingOnly(top: appStore.hasInFullScreen ? 0 : context.statusBarHeight),
              if (!appStore.hasInFullScreen) ...[
                8.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(parseHtmlString(widget.data.title.validate()), style: boldTextStyle(size: 22)),
                    4.height,
                    if (widget.data.duration.validate().isNotEmpty) Text(widget.data.duration.validate(), style: secondaryTextStyle(size: 16)),
                    8.height,
                    HtmlWidget(postContent: widget.data.description.validate(), color: textSecondaryColor),
                  ],
                ).paddingAll(16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
