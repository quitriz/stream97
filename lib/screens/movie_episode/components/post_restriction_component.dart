import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/movie_episode/components/login_bottom_sheet.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';


class PostRestrictionComponent extends StatelessWidget {
  final String imageUrl;
  final String restrictedPlans;
  final bool isPostRestricted;
  final VoidCallback? callToRefresh;

  const PostRestrictionComponent({super.key, required this.imageUrl, required this.isPostRestricted, required this.restrictedPlans, this.callToRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      height: appStore.hasInFullScreen ? context.height() - 25 : context.height() * 0.3,
      child: Stack(
        children: [
          CachedImageWidget(
            url: imageUrl,
            width: context.width(),
            height: appStore.hasInFullScreen ? context.height() - 25 : context.height() * 0.3,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha:0.7), width: context.width()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${language.thisContentIsFor}$restrictedPlans ${language.membersOnly}',
                style: primaryTextStyle(),
                textAlign: TextAlign.center,
              ).paddingSymmetric(horizontal: 20, vertical: 8),
              if (!mIsLoggedIn)
                LoginBottomSheet(
                  callToRefresh: () {},
                )
              else if (isPostRestricted)
                ElevatedButton(
                  onPressed: () {
                      MembershipPlansScreen(selectedPlanId: appStore.subscriptionPlanId).launch(context).then((v) {
                        if (v ?? false) {
                          callToRefresh?.call();
                        }
                      });
                  },
                  child: Text(language.joinNow, style: boldTextStyle(color: Colors.white)),
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorPrimary)),
                ),
            ],
          ).center(),
        ],
      ),
    );
  }
}