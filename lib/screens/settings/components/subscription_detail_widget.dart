import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_account_screen.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SubscriptionDetailWidget extends StatefulWidget {
  @override
  _SubscriptionDetailWidgetState createState() => _SubscriptionDetailWidgetState();
}

class _SubscriptionDetailWidgetState extends State<SubscriptionDetailWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SettingItemWidget(
          onTap: () async {
            MyAccountScreen().launch(context);
          },
          title: language!.myAccount,
          titleTextStyle: primaryTextStyle(color: Colors.white),
          subTitle: language!.reviewMembershipPlanAnd,
          leading: Image.asset(
            ic_user,
            height: 28,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        );
      },
    );
  }
}
