import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class NoMembershipComponent extends StatelessWidget {
  const NoMembershipComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CachedImageWidget(url: ic_badge, height: 80, width: 80, color: context.iconColor).center(),
        32.height,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: language!.youDontHaveMembership,
            style: primaryTextStyle(fontFamily: GoogleFonts.nunito().fontFamily),
            children: [
              WidgetSpan(
                child: Text(
                  language!.chooseAMembershipPlan,
                  style: primaryTextStyle(color: context.primaryColor, fontFamily: GoogleFonts.nunito().fontFamily),
                ).onTap(() {
                  MembershipPlansScreen().launch(context).then((v) {
                    if (v ?? false) {}
                  });
                }, highlightColor: Colors.transparent, splashColor: Colors.transparent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
