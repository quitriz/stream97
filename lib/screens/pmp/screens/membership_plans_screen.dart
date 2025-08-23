import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/screens/woo_commerce/woo_commerce_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class MembershipPlansScreen extends StatefulWidget {
  final String? selectedPlanId;
  final List<String>? requiredPlanIds;

  const MembershipPlansScreen({Key? key, this.selectedPlanId, this.requiredPlanIds}) : super(key: key);

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  List<MembershipModel> plans = [];

  Package? selectedInAppPlan;

  bool isError = false;

  MembershipModel? selectedPlan;

  Offering? inAppOffering;

  @override
  void initState() {
    super.initState();
    Future.wait(
      [
        getPlansList(),
        if (appStore.isInAppPurChaseEnable) getInAppPlan(),
      ],
    );
  }

  ///Helper methods to determine plan status
  bool _isPlanRecommended(MembershipModel plan) {
    if (widget.requiredPlanIds == null || widget.requiredPlanIds!.isEmpty) {
      return false;
    }
    return widget.requiredPlanIds!.contains(plan.id.toString());
  }

  ///Helper method to check if the user is on the current plan
  bool _isUserCurrentPlan(MembershipModel plan) {
    return appStore.subscriptionPlanId.isNotEmpty && plan.id.toString() == appStore.subscriptionPlanId;
  }

  ///Helper method to get the best recommended plan
  MembershipModel? _getBestRecommendedPlan() {
    if (widget.requiredPlanIds == null || widget.requiredPlanIds!.isEmpty) {
      return null;
    }
    List<MembershipModel> recommendedPlans = plans.where((plan) => widget.requiredPlanIds!.contains(plan.id.toString())).toList();

    if (recommendedPlans.isEmpty) return null;

    recommendedPlans.sort((a, b) => (a.billingAmount ?? 0).compareTo(b.billingAmount ?? 0));

    MembershipModel bestPlan = recommendedPlans.first;
    if (_isUserCurrentPlan(bestPlan)) {
      for (MembershipModel plan in recommendedPlans) {
        if (!_isUserCurrentPlan(plan)) {
          return plan;
        }
      }
      return null;
    }

    return bestPlan;
  }

  Future<void> getInAppPlan() async {
    appStore.setLoading(true);
    InAppPurchaseService.getMembershipPlanList().then((offering) {
      if (offering.current != null) {
        inAppOffering = offering.current!;
      }
    });
  }

  Future<void> getInAppPackageForSelectedPlan() async {
    if (inAppOffering!.availablePackages.validate().isNotEmpty) {
      int index = inAppOffering!.availablePackages
          .validate()
          .indexWhere((element) => element.storeProduct.identifier == (isIOS ? selectedPlan!.appStorePlanIdentifier : selectedPlan!.playStorePlanIdentifier.validate()));
      if (index > -1) selectedInAppPlan = inAppOffering!.availablePackages.validate()[index];

      if (selectedInAppPlan != null) {
        log('Selected Plan from Offerings: '
            'identifier: ${selectedInAppPlan!.identifier}, '
            'storeProduct: ${selectedInAppPlan!.storeProduct.identifier}, '
            'price: ${selectedInAppPlan!.storeProduct.priceString}');
        if (appStore.activeSubscriptionIdentifier == selectedInAppPlan!.storeProduct.identifier) {
          toast("This plan is already active kindly try to upgrade plan");
        } else {
          InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: selectedInAppPlan!, levelId: selectedPlan!.id.validate());
        }
      } else {
        toast(language.revenueCatIdentifierMissMach);
      }
    } else {
      toast(language.noOfferingsFound);
    }
  }

  Future<void> getPlansList() async {
    appStore.setLoading(true);
    plans.clear();
    await getLevelsList().then((value) {
      plans.addAll(value);
      if (plans.isNotEmpty) {
        if (widget.selectedPlanId.validate().isNotEmpty &&
            plans.any(
              (element) => element.productId == widget.selectedPlanId.validate(),
            ))
          selectedPlan = plans.firstWhere((el) => el.productId == widget.selectedPlanId.validate());
        else {
          if (widget.selectedPlanId == null) {
            selectedPlan = _getBestRecommendedPlan() ?? plans.first;
          }
        }
      }
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      log(e.toString());
      setState(() {});
      appStore.setLoading(false);
    });
  }

  Future<void> pmpPayment() async {
    await WebViewScreen(url: selectedPlan!.checkoutUrl.validate() + '&web_view_nonce=${appStore.userNonce}&user_id=${appStore.userId}', title: language.payment).launch(context).then((x) async {
      appStore.setLoading(true);
      await getMembershipLevelForUser(userId: appStore.userId.validate()).then((membershipPlan) {
        if (membershipPlan != null) {
          MembershipModel membership = MembershipModel.fromJson(membershipPlan);

          if (membership.id != appStore.subscriptionPlanId) {
            logout(logoutFromAll: true);
            HomeScreen().launch(context, isNewTask: true);
          }
        }
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        log('Error: ${e.toString()}');
      });
    });
  }

  Future<void> configurePaymentMethod(int index) async {
    if (selectedPlan!.id != getStringAsync(SUBSCRIPTION_PLAN_ID).trim()) {
      if (appStore.isLoading) return;

      // Skip payment message for free plans
      if (selectedPlan!.billingAmount.validate().toDouble() == 0.0) {
        InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: null, levelId: selectedPlan!.id.validate(), isFreePlan: true);
        return;
      }

      if (index == 0) {
        finish(context, true);
        pmpPayment();
      } else if (index == 1) {
        finish(context, true);
        WooCommerceScreen(orderId: selectedPlan!.productId.validate()).launch(context);
      } else if (index == 2) {
        getInAppPackageForSelectedPlan();
      }
    } else {
      toast('Selected subscription plan is already active.Try to upgrade the plan');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    if (appStore.isLoading) appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(language.membershipPlans, style: boldTextStyle()),
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            if (plans.isNotEmpty)
              ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (ctx, index) {
                  MembershipModel plan = plans[index];
                  bool isRecommended = _isPlanRecommended(plan);
                  bool isCurrentPlan = _isUserCurrentPlan(plan);

                  if (plan.name.validate().isNotEmpty)
                    return GestureDetector(
                      onTap: () {
                        if (isCurrentPlan) return;

                        if (selectedPlan == plan) {
                          selectedPlan = null;
                          setState(() {});
                        } else {
                          selectedPlan = plan;
                          setState(() {});
                        }
                      },
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isCurrentPlan
                                      ? appGreenColor
                                      : selectedPlan == plan
                                          ? context.primaryColor
                                          : isRecommended
                                              ? colorAccent.withValues(alpha: 0.7)
                                              : textColorThird),
                              color: isCurrentPlan
                                  ? appGreenColor.withAlpha(20)
                                  : selectedPlan == plan
                                      ? context.primaryColor.withAlpha(30)
                                      : isRecommended
                                          ? colorAccent.withAlpha(10)
                                          : context.cardColor,
                              borderRadius: radius()
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    /// Recommended tag
                                    if (isRecommended)
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorAccent,
                                          borderRadius: radius(4),
                                        ),
                                        child: Text(language.recommended, style: boldTextStyle(color: Colors.white, size: 12)),
                                      ),
                                    if (isCurrentPlan)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: appGreenColor,
                                          borderRadius: radius(4),
                                        ),
                                        child: Text(language.yourPlan, style: boldTextStyle(color: Colors.white, size: 12)),
                                      ),
                                  ],
                                ),
                                if (isRecommended || isCurrentPlan) 8.height,
                                Text(plan.name.validate(), style: boldTextStyle()),
                                if (plan.description.validate().isNotEmpty) Text(plan.description.validate(), style: secondaryTextStyle()).paddingSymmetric(vertical: 6),
                                if (plan.initialPayment == 0 && plan.billingAmount == 0)
                                  Text(language.free, style: boldTextStyle())
                                else if (plan.initialPayment == plan.billingAmount)
                                  Text(
                                    '${appStore.pmpCurrency}${plan.initialPayment} ${plan.cycleNumber == '1' ? 'per ${plan.cyclePeriod}' : 'every ${plan.cycleNumber} ${plan.cyclePeriod}'}',
                                    style: boldTextStyle(),
                                  )
                                else if (plan.initialPayment != plan.billingAmount)
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '${appStore.pmpCurrency}${plan.initialPayment}',
                                          style: boldTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                        TextSpan(
                                          text: ' now and then',
                                          style: primaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${appStore.pmpCurrency}${plan.initialPayment} ${plan.cycleNumber == '1' ? 'per ${plan.cyclePeriod}' : 'every ${plan.cycleNumber} ${plan.cyclePeriod}'}',
                                          style: boldTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                        TextSpan(
                                          text: ' for ${plan.billingAmount == 1 ? 'per ${plan.cyclePeriod}' : 'every ${plan.billingAmount} ${plan.cyclePeriod}'}',
                                          style: boldTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                        TextSpan(
                                          text: ' After your initial payment, your first',
                                          style: primaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                        TextSpan(
                                          text: '${plan.trialLimit} payments will cost ${appStore.pmpCurrency}${plan.trialAmount}.',
                                          style: primaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (plan.expirationNumber != "0" && plan.expirationPeriod.validate().isNotEmpty)
                                  Text(
                                    '${language.membershipExpiresAfter} ${plan.expirationNumber} ${plan.expirationPeriod}.',
                                    style: secondaryTextStyle(),
                                  ),
                              ],
                            ),
                          ),
                          if (!isCurrentPlan)
                            Positioned(
                              child: IconButton(
                                onPressed: () {
                                  if (selectedPlan == plan) {
                                    selectedPlan = null;
                                    setState(() {});
                                  } else {
                                    selectedPlan = plan;
                                    setState(() {});
                                  }
                                },
                                icon: Icon(
                                  selectedPlan == plan ? Icons.radio_button_checked : Icons.circle_outlined,
                                  color: selectedPlan == plan ? context.primaryColor : context.iconColor,
                                ),
                                splashColor: colorPrimary.withValues(alpha: 0.2),
                                highlightColor: colorPrimary.withValues(alpha: 0.2),
                              ),
                              right: appStore.selectedLanguageCode != 'ar' ? 0 : null,
                              left: appStore.selectedLanguageCode == 'ar' ? 0 : null,
                              top: 8,
                            )
                        ],
                      ),
                    );
                  else
                    return Offstage();
                },
              ),
            if (plans.isEmpty && !appStore.isLoading && !isError)
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noData,
              ).center(),
            if (isError && !appStore.isLoading)
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.somethingWentWrong,
              ).center(),
            if (appStore.isLoading) LoaderWidget().center(),
          ],
        ),
      ),
      bottomNavigationBar: selectedPlan != null && !appStore.isLoading
          ? AppButton(
              width: context.width() - 32,
              text: language.selectAndProceed,
              color: context.primaryColor,
              onTap: () {
                // Skip payment for free plans
                if (selectedPlan!.billingAmount.validate().toDouble() == 0.0) {
                  InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: null, levelId: selectedPlan!.id.validate(), isFreePlan: true);
                  return;
                }

                if (appStore.isInAppPurChaseEnable) {
                  configurePaymentMethod(2);
                } else {
                  pmpPayment();
                }
              },
            ).paddingAll(16)
          : Offstage(),
    );
  }
}
