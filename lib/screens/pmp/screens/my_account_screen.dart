import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/pmp/components/no_membership_component.dart';
import 'package:streamit_flutter/screens/pmp/components/past_invoices_component.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/screens/woo_commerce/woo_orders_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

class MyAccountScreen extends StatefulWidget {
  final bool fromRegistration;

  MyAccountScreen({this.fromRegistration = false});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  MembershipModel? membership;

  bool hasMembership = false;
  bool hasError = false;

  bool isRestoreRequired = false;

  @override
  void initState() {
    super.initState();
    getMembership();
  }

  Future<void> getMembership() async {
    appStore.setLoading(true);
    await getMembershipLevelForUser(userId: appStore.userId.validate()).then((value) {
      if (value != null) {
        if (value != false) {
          hasMembership = true;
          if (appStore.isInAppPurChaseEnable && appStore.activeSubscriptionIdentifier.isNotEmpty) {
            if (InAppPurchaseService.activeStoreProduct != null) {
              isRestoreRequired = getBoolAsync(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED);
            }
          }
        } else {
          hasMembership = false;
        }

        appStore.setLoading(false);
      } else {
        hasMembership = false;
        appStore.setLoading(false);
      }
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult:(didPop, result) {
        if (widget.fromRegistration) {
          HomeScreen().launch(context, isNewTask: true);
        } else {
          finish(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          centerTitle: true,
          title: Text(language.myAccount, style: boldTextStyle()),
          leading: BackButton(
            onPressed: () {
              if (widget.fromRegistration) {
                HomeScreen().launch(context, isNewTask: true);
              } else {
                finish(context);
              }
            },
          ),
        ),
        body: Observer(
          builder: (BuildContext context) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CachedImageWidget(
                              url: appStore.userProfileImage.validate(),
                              fit: appStore.userProfileImage.validate().contains("http") ? BoxFit.cover : BoxFit.cover,
                              height: 46,
                              width: 46,
                            ),
                          ),
                          16.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appStore.userName.validate(), style: primaryTextStyle()),
                              Text(appStore.userEmail.validate(), style: secondaryTextStyle()),
                            ],
                          ),
                        ],
                      ),
                      16.height,
                      if (!hasError) hasMembership ? Text(language.myMemberships, style: boldTextStyle()).paddingSymmetric(horizontal: 16) : Offstage(),
                      16.height,
                      if (!hasError)
                        hasMembership
                            ? Observer(
                                builder: (context) {
                                  return Container(
                                    width: context.width(),
                                    margin: EdgeInsets.only(left: 16, right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha:0.5), blurRadius: 3)],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  appStore.subscriptionPlanName.validate(),
                                                  style: primaryTextStyle(color: white, size: 24),
                                                ),
                                                if (appStore.subscriptionPlanExpDate.validate().toInt() != 0)
                                                  Text(
                                                    language.validTill + DateTime.fromMillisecondsSinceEpoch(appStore.subscriptionPlanExpDate.validate().toInt() * 1000).toString().getFormattedDate()!,
                                                    style: primaryTextStyle(color: white),
                                                  ),
                                              ],
                                            ).expand(),
                                            if (appStore.isInAppPurChaseEnable) 16.width,
                                            if (appStore.isInAppPurChaseEnable && getBoolAsync(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED))
                                              AppButton(
                                                color: appGreenColor.withAlpha(20),
                                                onTap: () {
                                                  appStore.setLoading(true);
                                                  InAppPurchaseService.restoreSubscription(context).then((value) async {
                                                    await 1.seconds.delay;
                                                    setState(() {});
                                                    appStore.setLoading(false);
                                                  }).catchError((e) {
                                                    toast(e.toString(), print: true);
                                                    appStore.setLoading(false);
                                                  });
                                                },
                                                text: "Restore",
                                                textColor: appGreenColor,
                                                margin: EdgeInsets.all(0),
                                              )
                                          ],
                                        ).paddingOnly(top: 8, left: 16, right: 16, bottom: 4),
                                        AppButton(
                                          child: Text(language.upgradePlan, style: boldTextStyle(color: white)),
                                          color: colorPrimary,
                                          onTap: () async {
                                            MembershipPlansScreen(selectedPlanId: appStore.subscriptionPlanId).launch(context).then((v) {
                                              if (v ?? false) getMembership();
                                            });
                                          },
                                          width: context.width(),
                                        ).paddingOnly(left: 8, right: 8, top: 8, bottom: 8)
                                      ],
                                    ),
                                  );
                                },
                              )
                            : NoMembershipComponent()
                      else
                        NoDataWidget(
                          imageWidget: noDataImage(),
                          title: language.somethingWentWrong,
                        ).center(),
                      PastInvoicesComponent().paddingSymmetric(horizontal: 16),
                      TextButton(
                        child: Text(
                          '${language.viewOrdersOf} ${language.africanMobilePayment}',
                          style: primaryTextStyle(color: colorPrimary),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          OrdersScreen().launch(context);
                        },
                      ).paddingSymmetric(horizontal: 2)
                    ],
                  ),
                ),
                LoaderWidget().visible(appStore.isLoading),
              ],
            );
          },
        ),
      ),
    );
  }
}