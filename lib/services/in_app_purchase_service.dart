import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';

import '../utils/constants.dart';

class InAppPurchaseService {
  static String entitlementId = '';
  static String subscriptionExpirationDate = "";
  static CustomerInfo? userInfo;
  static Offerings? inAppOfferings;
  static StoreProduct? activeStoreProduct;

  static Future<void> init() async {
    try {
      entitlementId = appStore.inAppEntitlementID;
      await Purchases.setLogLevel(LogLevel.info);
      final String apiKey = isIOS ? appStore.inAppAppleApiKey : appStore.inAppGoogleApiKey;

      if (apiKey.isNotEmpty) {
        PurchasesConfiguration configuration = PurchasesConfiguration(apiKey)
          ..appUserID = appStore.userEmail.validate();

        await Purchases.configure(configuration);
        loginToRevenueCate();
      } else {}
    } catch (e) {
      log('In App Purchase Configuration Failed: ${e.toString()}');
    }
  }

  static Future<void> loginToRevenueCate() async {
    try {
      await Purchases.logIn(appStore.userEmail.validate());
      setValue(HAS_IN_APP_SDK_INITIALISE_AT_LEASE_ONCE, true);
      getCustomerInfo();
    } catch (e) {
      log('In App Purchase User Login Failed: ${e.toString()}');
    }
  }

  static Future<void> getCustomerInfo({bool restore = false, BuildContext? context}) async {
    final customerInfo = await Purchases.getCustomerInfo();
    userInfo = customerInfo;
    if (customerInfo.activeSubscriptions.isNotEmpty) {
      /// Updating new order in Database
      if (appStore.activeSubscriptionIdentifier != customerInfo.activeSubscriptions.first) {
        await getMembershipPlanList().then((offers) async {
          int index = offers.current!.availablePackages.validate().indexWhere((element) => element.storeProduct.identifier == customerInfo.activeSubscriptions.first);
          if (index > -1) {
            StoreProduct? activeSubscription = offers.current!.availablePackages.validate()[index].storeProduct;
            await getLevelsList().then((value) async {
              int j = value.indexWhere((element) => (isIOS ? element.appStorePlanIdentifier == activeSubscription.identifier : element.playStorePlanIdentifier == activeSubscription.identifier));
              if (j > -1) {
                setValue(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED, true);
                if (restore) {
                  Map<String, dynamic> request = {
                    "billing_amount": activeSubscription.priceString,
                    "gateway": "in_app_purchase",
                    "payment_by": isAndroid ? "google_payment" : "apple_payment",
                    "email": appStore.userEmail,
                    "contact": "",
                    "meta_value": "",
                    "level_id": value[j].id,
                    "gateway_mode": isAndroid ? "Google" : "Apple",
                    "is_active_subscription": true,
                    "in_app_purchase_identifier": activeSubscription.identifier,
                  };
                  await handleSuccessfulPurchase(request, context, false);
                }
              }
            });
          }
        });
      }
    } else {
      if (appStore.subscriptionPlanStatus == userPlanStatus && appStore.subscriptionPlanAmount.validate().toInt() != 0) {
        cancelMembershipLevel(levelId: appStore.subscriptionPlanId.validate());
      } else {
        log('----------------No Active Subscriptions----------------------------');
      }
    }
  }

  static Future<Offerings> getMembershipPlanList() async {
    if (!getBoolAsync(HAS_IN_APP_SDK_INITIALISE_AT_LEASE_ONCE, defaultValue: false)) {
      await init();
    }
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      if (e is PlatformException) {
        toast(e.message, print: true);
      } else {
        log(e.toString());
      }
      rethrow; // Re-throw the exception after logging it
    }
  }

  static Future<void> buySubscriptionPlan(BuildContext context, {Package? planToPurchase, bool isFreePlan = false, required String levelId}) async {
    try {
      log('Attempting to Buy Plan');
      // appStore.setLoading(true);
      if (!isFreePlan) {
        final purchaseResult  = await Purchases.purchasePackage(
          planToPurchase!,
          googleProductChangeInfo: appStore.activeSubscriptionIdentifier.isNotEmpty && appStore.activeSubscriptionIdentifier != (isIOS ? freePlanAppleIdentifier : freePlanGoogleIdentifier)
              ? GoogleProductChangeInfo(
            appStore.activeSubscriptionIdentifier,
            prorationMode: GoogleProrationMode.immediateAndChargeProratedPrice,
          )
              : null,
        );
        final customerInfo = purchaseResult.customerInfo;
        toast("Hold on!We're saving your subscription");
        EntitlementInfo? entitlement = customerInfo.entitlements.all[appStore.inAppEntitlementID];
        log('Activated plan');
        log(entitlement!.productPlanIdentifier);

        if (customerInfo.entitlements.all[appStore.inAppEntitlementID] != null) subscriptionExpirationDate = customerInfo.entitlements.all[appStore.inAppEntitlementID]!.expirationDate.validate();
      } else {
        cancelSubscription();
      }
      Map<String, dynamic> request = {
        "billing_amount": isFreePlan ? "0" : planToPurchase?.storeProduct.priceString,
        "gateway": "in_app_purchase",
        "payment_by": isAndroid ? "google_payment" : "apple_payment",
        "email": appStore.userEmail,
        "contact": "",
        "meta_value": "",
        "level_id": levelId,
        "gateway_mode": isAndroid ? "Google" : "Apple",
        "is_active_subscription": true,
      };

      if (!isFreePlan) request.putIfAbsent("in_app_purchase_identifier", () => planToPurchase?.storeProduct.identifier);

      await handleSuccessfulPurchase(request, context, isFreePlan);

      /// Purpose of setting this is to handle cases where purchase through PlayStore is successful but storing it database fails for any reason
      Future.delayed(
        Duration(minutes: 5),
        () {
          if (!getBoolAsync(HAS_PURCHASE_STORED)) {
            // Set up periodic check
            retryPendingSubscriptionData(context: context);
          }
        },
      );
    } catch (e) {
      appStore.setLoading(false);
      if (e is PlatformException) {
        log('Purchase Failed: ${e.message}');
        toast(e.message, print: true);
      } else {
        if (e is PurchasesError) {
          if (e.code == 'ProductAlreadyPurchasedError') {}
        } else {
          log('Purchase Failed: ${e.toString()}');
        }
      }
    }
  }

  static Future<void> handleSuccessfulPurchase(Map<String, dynamic> request, BuildContext? ctx, bool wasFreePlan) async {
    appStore.setLoading(true);
    await generateInAppOrder(request).then((order) async {
      appStore.setLoading(false);
      appStore.setSubscriptionPlanStatus(userPlanStatus);
      if (ctx != null) finish(ctx, true);
      appStore.setSubscriptionPlanName(order.membershipName.validate());
      appStore.setSubscriptionPlanId(order.membershipId.validate());
      if (!wasFreePlan) appStore.setActiveSubscriptionIdentifier(request["in_app_purchase_identifier"]);
      if (!wasFreePlan) appStore.setSubscriptionPlanExpDate(subscriptionExpirationDate);
      setValue(HAS_PURCHASE_STORED, true);
      setValue(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED, false);
    }).catchError((e) {
      saveSubscriptionDataLocally(request);
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  static Future<void> retryPendingSubscriptionData({BuildContext? context}) async {
    Map<String, dynamic>? pendingData = await getPendingSubscriptionData();
    if (pendingData != null) {
      try {
        await handleSuccessfulPurchase(pendingData, context, (pendingData["in_app_purchase_identifier"] as String).isNotEmpty).then((v) {
          clearPendingSubscriptionData();
        });
      } catch (e) {
        log('Retry Failed: ${e.toString()}');
      }
    } else {}
  }

  static Future<void> cancelSubscription() async {
    appStore.setLoading(true);
    userInfo = await Purchases.getCustomerInfo();
    if (userInfo?.managementURL != null) {
      await launchCustomTabURL(url: userInfo!.managementURL.validate()).then((v) {
        appStore.setActiveSubscriptionIdentifier(isIOS ? freePlanAppleIdentifier : freePlanGoogleIdentifier);
      });
    } else {
      appStore.setLoading(false);
    }
  }

  static Future<void> restoreSubscription(BuildContext context) async {
    getCustomerInfo(restore: true);
  }
}

Future<void> saveSubscriptionDataLocally(Map<String, dynamic> request) async {
  setValue(PURCHASE_REQUEST, jsonEncode(request));
  setValue(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED, true);
}

Future<Map<String, dynamic>?> getPendingSubscriptionData() async {
  String? data = getStringAsync(PURCHASE_REQUEST);
  return jsonDecode(data);
}

Future<void> clearPendingSubscriptionData() async {
  removeKey(HAS_PURCHASE_STORED);
  removeKey(PURCHASE_REQUEST);
  removeKey(IS_SUBSCRIPTION_PURCHASE_RESTORE_REQUIRED);
}
