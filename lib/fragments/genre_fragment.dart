import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/settings/screens/edit_profile_screen.dart';
import 'package:streamit_flutter/screens/genre/genrelist_screen.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class GenreFragment extends StatefulWidget {
  static String tag = '/Genre  Fragment';

  @override
  GenreFragmentState createState() => GenreFragmentState();
}

class GenreFragmentState extends State<GenreFragment> {
  int index = 0;
  String? data;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBackground,
          centerTitle: false,
          title: CachedImageWidget(
              url: appStore.appLogo.validate().isNotEmpty
                  ? appStore.appLogo.validate()
                  : ic_logo,
              height: 32,
              width: 120),
          automaticallyImplyLeading: false,
          actions: [
            appStore.isLogging
                ? Container(
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: CachedImageWidget(
                      url: appStore.userProfileImage.validate(),
                      fit: appStore.userProfileImage.validate().contains("http")
                          ? BoxFit.cover
                          : null,
                    ).onTap(() {
                      EditProfileScreen().launch(context);
                    }, borderRadius: BorderRadius.circular(60)),
                  )
                : CachedImageWidget(
                        url: add_user,
                        width: 20,
                        height: 20,
                        color: Colors.white)
                    .paddingAll(16)
                    .onTap(() {
                    SignInScreen(
                      redirectTo: () {
                        appStore.setBottomNavigationIndex(2);
                      },
                    ).launch(context);
                  }, borderRadius: BorderRadius.circular(60)),
          ],
          bottom: PreferredSize(
            preferredSize: Size(context.width(), 45),
            child: TabBar(
              indicatorWeight: 0.0,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: boldTextStyle(size: ts_small.toInt()),
              indicatorColor: colorPrimary,
              indicator: TabIndicator(),
              onTap: (i) {
                index = i;
                setState(() {});
              },
              unselectedLabelStyle: secondaryTextStyle(size: ts_small.toInt()),
              unselectedLabelColor:
                  Theme.of(context).textTheme.titleLarge!.color,
              labelColor: colorPrimary,
              labelPadding: EdgeInsets.only(left: 16, right: 16),
              tabAlignment: TabAlignment.fill,
              tabs: [
                Tab(child: Marquee(child: Text(language!.movies))),
                Tab(child: Marquee(child: Text(language!.tVShows))),
                Tab(child: Marquee(child: Text(language!.videos))),
                // Tab(child: Text("Live")),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GenreListScreen(type: dashboardTypeMovie),
            GenreListScreen(type: dashboardTypeTVShow),
            GenreListScreen(type: dashboardTypeVideo),
            // GenreListScreen(type: dashboardTypeLive),
          ],
        ).makeRefreshable,
      ),
    );
  }
}
