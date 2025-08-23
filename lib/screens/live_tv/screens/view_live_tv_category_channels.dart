import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/live_tv/live_category_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_tv_category_item_component.dart';
import 'package:streamit_flutter/utils/common.dart';

class ViewLiveTvCategoryChannels extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ViewLiveTvCategoryChannels({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  _ViewLiveTvCategoryChannelsState createState() => _ViewLiveTvCategoryChannelsState();
}

class _ViewLiveTvCategoryChannelsState extends State<ViewLiveTvCategoryChannels> {
  Future<LiveCategoryList>? future;
  List<CategoryData> channelList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    try {
      future = fetchCategoryChannels(widget.categoryId).then((value) {
        channelList.clear();
        channelList.addAll(value.data ?? []);
        print('Loaded channels: \\${channelList.length}');
        setState(() {});
        appStore.setLoading(false);
        return value;
      });
    } catch (e, st) {
      print('Error loading channels: \\${e}\\n\\${st}');
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName, style: boldTextStyle(color: Colors.white, size: 20)), backgroundColor: context.cardColor, centerTitle: false),
      body: Stack(
        children: [
          SnapHelperWidget(
            future: future,
            loadingWidget: Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading).center()),
            errorBuilder: (p0) {
              print('SnapHelperWidget error: \\${p0}');
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: p0,
                onRetry: () {
                  init();
                },
                retryText: language.refresh,
              ).center();
            },
            onSuccess: (LiveCategoryList data) {
              print('onSuccess called. ChannelList length: \\${channelList.length}');
              if (channelList.isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: 'No channels found',
                  onRetry: () {
                    init();
                  },
                  retryText: language.refresh,
                ).center();
              else
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: channelList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.6),
                  itemBuilder: (context, index) {
                    final channel = channelList[index];
                    return LiveChannelCardItemComponent(channel: channel);
                  },
                );
            },
          ),
          Observer(
            builder: (context) {
              return LoaderWidget().visible(appStore.isLoading);
            },
          )
        ],
      ),
    );
  }
}
