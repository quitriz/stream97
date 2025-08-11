import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/auth/sign_up.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../pmp/screens/membership_plans_screen.dart';

class LoginBottomSheet extends StatelessWidget {
  final VoidCallback? callToRefresh;

  const LoginBottomSheet({super.key, this.callToRefresh});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(32), topLeft: Radius.circular(32))),
          context: context,
          isScrollControlled: true,
          enableDrag: false,
          backgroundColor: context.cardColor,
          builder: (_) => FractionallySizedBox(
            heightFactor: !mIsLoggedIn ? 0.4 : 0.2,
            widthFactor: 1.0,
            child: DraggableScrollableSheet(
              initialChildSize: !mIsLoggedIn ? 1.0 : 0.5,
              minChildSize: !mIsLoggedIn ? 0.95 : 0.5,
              builder: (_, controller) {
                return Stack(
                  children: [
                    Container(
                      height: !mIsLoggedIn ? context.height() * 0.4 : context.height() * 0.15,
                      width: context.width(),
                      color: context.cardColor,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!appStore.isLogging) ...[
                              20.height,
                              Text(language!.youMustBeLogged, style: primaryTextStyle()),
                              16.height,
                              ElevatedButton(
                                onPressed: () {
                                  finish(context);
                                  SignUpScreen().launch(context);
                                },
                                child: Text(language!.registerNow, style: boldTextStyle()),
                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorPrimary)),
                              ),
                              16.height,
                              Text(language!.alreadyAMember, style: primaryTextStyle()),
                              TextButton(
                                onPressed: () {
                                  finish(context);
                                  SignInScreen(
                                    redirectTo: () {},
                                  ).launch(context);
                                },
                                child: Text(language!.loginNow, style: boldTextStyle(color: context.primaryColor)),
                              ),
                            ] else
                              ElevatedButton(
                                onPressed: () {
                                  finish(context);
                                    MembershipPlansScreen(
                                      selectedPlanId: appStore.subscriptionPlanId,
                                    ).launch(context).then((v) {
                                      if (v ?? false) {
                                        callToRefresh?.call();
                                      }
                                    });
                                },
                                child: Text(language!.joinNow, style: boldTextStyle(color: Colors.white)),
                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorPrimary)),
                              ),
                          ],
                        ).center(),
                      ),
                    ).cornerRadiusWithClipRRectOnly(topRight: 32, topLeft: 32),
                  ],
                );
              },
            ),
          ),
        );
      },
      child: Text(language!.viewInfo, style: boldTextStyle(color: Colors.white)),
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorPrimary)),
    );
  }
}