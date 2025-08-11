import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/cast/cast_detail_tab_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class PersonalInfoWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  PersonalInfoWidget({required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: context.width() / 2 - 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.validate(),
            style: boldTextStyle(color: colorPrimary.withValues(alpha:0.8), size: 20),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).paddingAll(4),
          Text(subTitle.validate(), style: primaryTextStyle(color: Colors.white, size: 14)).paddingBottom(4),
        ],
      ),
    );
  }
}

class CastBottomSheet extends StatefulWidget {
  final String? castId;

  const CastBottomSheet({super.key, this.castId});

  @override
  State<CastBottomSheet> createState() => _CastBottomSheetState();
}

class _CastBottomSheetState extends State<CastBottomSheet> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    _controller = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      height: context.height() * 0.7,
      decoration: BoxDecoration(
        color: scaffoldDarkColor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: TabBar(
              controller: _controller,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
              labelStyle: TextStyle(fontSize: ts_normal),
              indicatorColor: colorPrimary,
              indicator: TabIndicator(),
              unselectedLabelColor: Theme.of(context).textTheme.titleLarge!.color,
              labelColor: colorPrimary,
              tabs: [
                Tab(child: Text(language!.all)),
                Tab(child: Text(language!.movies)),
                Tab(child: Text(language!.tVShows)),
              ],
            ),
          ),
          Container(
            height: context.height() * 0.7 - kToolbarHeight,
            child: TabBarView(
              controller: _controller,
              children: [
                CastDetailTabWidget(type: '', castId: widget.castId.toInt()),
                CastDetailTabWidget(type: dashboardTypeMovie, castId: widget.castId.toInt()),
                CastDetailTabWidget(type: dashboardTypeTVShow, castId: widget.castId.toInt()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
