import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../../../components/loader_widget.dart';
import '../../../components/loading_dot_widget.dart';
import '../../../main.dart';
import '../../../models/movie_episode/common_data_list_model.dart';
import '../../../models/view_all_response.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/common.dart';

class ViewAllLiveTvChannels extends StatefulWidget {
  final String categoryTitle;
  final int sliderIndex;
  final String? type;
  List<dynamic>? typeId = [];

   ViewAllLiveTvChannels({Key? key, required this.categoryTitle, required this.sliderIndex, this.type, this.typeId}) : super(key: key);

  @override
  _ViewAllLiveTvChannelsState createState() => _ViewAllLiveTvChannelsState();
}

class _ViewAllLiveTvChannelsState extends State<ViewAllLiveTvChannels> {
  Future<ViewAllResponse>? future;
  List<CommonDataListModel> channelList = [];

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(true);
    future = viewAll(widget.sliderIndex, widget.type.validate(), postType: PostType.CHANNEL, page: page,list: (widget.typeId is List) ? widget.typeId : []).then((value) {
      if (page == 1) channelList.clear();
      mIsLastPage = value.data!.length == postPerPage;

      channelList.addAll(value.data!);

      setState(() {});

      appStore.setLoading(false);
      return value;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: boldTextStyle(color: Colors.white, size: 20)),
        backgroundColor: context.scaffoldBackgroundColor,
        surfaceTintColor: context.scaffoldBackgroundColor,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SnapHelperWidget(
            future: future,
            loadingWidget: Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading).center()),
            errorBuilder: (p0) {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: p0,
                onRetry: () {
                  setState(() {
                    mPage = 1;
                  });
                  init(showLoader: true, page: mPage);
                },
                retryText: language!.refresh,
              ).center();
            },
            onSuccess: (data) {
              if (channelList.isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: '${language!.noDataFound} for ${widget.categoryTitle}',
                  onRetry: () {
                    setState(() {
                      mPage = 1;
                    });
                    init(showLoader: true, page: mPage);
                  },
                  retryText: language!.refresh,
                ).center();
              else
                return AnimatedScrollView(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                  onSwipeRefresh: () async {
                    return await init();
                  },
                  onNextPage: () {
                    if (!mIsLastPage) {
                      setState(() {
                        mPage++;
                      });
                      init(page: mPage);
                    }
                  },
                  children: [
                    AnimatedWrap(
                      children: channelList.map(
                        (e) {
                          return CommonListItemComponent(
                            data: e,
                            isLandscape: true,
                            width: context.width() / 2 - 24,
                            isLive: true,
                          );
                        },
                      ).toList(),
                      runSpacing: 16,
                      spacing: 16,
                    )
                  ],
                );
            },
          ),
          Observer(
            builder: (context) {
              return mPage > 1
                  ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: LoadingDotsWidget(),
                    ).visible(appStore.isLoading)
                  : LoaderWidget().visible(appStore.isLoading);
            },
          )
        ],
      ),
    );
  }
}