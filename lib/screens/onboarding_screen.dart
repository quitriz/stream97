import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class OnBoardingScreen extends StatefulWidget {
  static String tag = '/OnBoardingScreen';

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndexPage = 0;
  PageController controller = PageController();
  List<Widget> listItem = [];

  @override
  void initState() {
    listItem.addAll([
      WalkThrough(title: walk_titles[0], subtitle: walk_sub_titles[0], walkthroughImage: ic_walkthrough1),
      WalkThrough(title: walk_titles[1], subtitle: walk_sub_titles[1], walkthroughImage: ic_walkthrough2),
      WalkThrough(title: walk_titles[2], subtitle: walk_sub_titles[2], walkthroughImage: ic_walkthrough3),
    ]);
    super.initState();
    setStatusBarColor(Colors.transparent);
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            PageView(
              controller: controller,
              children: listItem,
              onPageChanged: (value) {
                setState(() => currentIndexPage = value);
              },
            ),
            Positioned(
              child: TextButton(
                onPressed: () {
                  HomeScreen().launch(context, isNewTask: true);
                },
                child: Text(language.skip, style: primaryTextStyle(color: context.primaryColor)),
              ),
              top: 30,
              right: 8,
            ),
            Positioned(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: listItem.map((e) {
                      int index = listItem.indexOf(e);
                      return AnimatedContainer(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.bounceInOut,
                        height: 10,
                        width: index == currentIndexPage ? 28 : 10,
                        decoration: BoxDecoration(
                          color: index == currentIndexPage ? colorPrimary : colorPrimary.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(index == currentIndexPage ? 8 : 100),
                        ),
                      );
                    }).toList(),
                  ),
                  Container(
                    decoration: boxDecorationDefault(color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha:0.7), borderRadius: radius(28), boxShadow: []),
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ).paddingAll(spacing_standard_new).onTap(() {
                    if (currentIndexPage == listItem.length - 1) {
                      if (mIsLoggedIn) {
                        HomeScreen().launch(context, isNewTask: true);
                      } else {
                        if (getStringAsync(TOKEN).isNotEmpty && JwtDecoder.isExpired(getStringAsync(TOKEN))) {
                          logout();
                        } else {
                          HomeScreen().launch(context, isNewTask: true);
                        }
                      }
                    } else {
                      if (currentIndexPage != listItem.length - 1)
                        controller.animateToPage(currentIndexPage + 1, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
                      else
                        HomeScreen().launch(context, isNewTask: true);
                    }
                    setState(() {});
                  }).paddingBottom(spacing_standard_new)
                ],
              ),
              bottom: 16,
              right: 16,
              left: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class WalkThrough extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? walkthroughImage;

  WalkThrough({Key? key, this.title, this.subtitle, this.walkthroughImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(image: DecorationImage(image: AssetImage(walkthroughImage.validate()), fit: BoxFit.fill)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title!, style: boldTextStyle(size: 22, color: Colors.white)),
          16.height,
          Text(subtitle!, style: secondaryTextStyle(size: 14, color: Colors.white), textAlign: TextAlign.center, maxLines: 2).paddingSymmetric(horizontal: 12),
        ],
      ).paddingTop(context.height() * 0.36).paddingSymmetric(horizontal: 16),
    );
  }
}
