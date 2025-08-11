import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/onboarding_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() async {
      getDeviceInfo();
      navigationToDashboard();
      await getSettings();
      await getDashboardSettings();
    });
  }

  Future<void> getDashboardSettings() async {
    await getSettings()
        .then((value) {
          appStore.setShowItemName(value.showTitles == 1);
          appStore.setPmpCurrency(parseHtmlString(value.pmproCurrency));
          appStore.setCurrencySymbol(value.currencySymbol);
          appStore.setMovieTypeCommentsOnOff(value.comment!.movieComments == 1);
          appStore.setTVShowCommentsOnOff(value.comment!.tvShowComments == 1);
          appStore.setVideoTypeCommentsOnOff(value.comment!.videoComments == 1);
          appStore.setEpisodeTypeCommentsOnOff(
            value.comment!.episodeComments == 1,
          );
          appStore.setAdsVisibility(value.showAds == 1);
          appStore.setEnableMembership(value.isMembershipEnabled.getBoolInt());
          appStore.setEnableLiveStreaming(value.isLiveEnabled.validate());
          appStore.setInAppPurchaseAvailable(
            value.isPaymentMethodAvailable &&
                value.pmproPayments?.type == PMProPayments.inAppPayment,
          );
          if (value.isPaymentMethodAvailable &&
              value.pmproPayments?.type == PMProPayments.inAppPayment) {
            appStore.setInAppEntitlementID(value.pmproPayments!.entitlementId);
            appStore.setInAppGoogleApiKey(value.pmproPayments!.googleApiKey);
            appStore.setInAppAppleApiKey(value.pmproPayments!.appleApiKey);
          }
        })
        .catchError(onError);
  }

  Future<void> getDeviceInfo() async {
    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      deviceId = info.identifierForVendor.validate();
    }

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      deviceId = info.id.validate();
    }
  }

  void navigationToDashboard() async {
    if (getBoolAsync(isLoggedIn) &&
        !JwtDecoder.isExpired(getStringAsync(TOKEN))) {
      await 2.seconds.delay;

      if (appStore.isLogging) {
        await validateToken(deviceId: deviceId)
            .then((value) async {
              if (!value.status.validate()) {
                logout();
              }
            })
            .catchError((e) async {
              logout();
            });
      }
    } else {
      await 2.seconds.delay;
    }

    mIsLoggedIn =
        getBoolAsync(isLoggedIn) &&
        !JwtDecoder.isExpired(getStringAsync(TOKEN));

    if (getBoolAsync(isFirstTime, defaultValue: true)) {
      await setValue(isFirstTime, false);
      OnBoardingScreen().launch(context, isNewTask: true);
    } else if (mIsLoggedIn) {
      if (appStore.isInAppPurChaseEnable) {
        InAppPurchaseService.init();
      }
      HomeScreen().launch(context, isNewTask: true);
    } else {
      if (getStringAsync(TOKEN).isNotEmpty &&
          JwtDecoder.isExpired(getStringAsync(TOKEN))) {
        logout();
      } else {
        HomeScreen().launch(context, isNewTask: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Image.asset(ic_logo).center(),
    );
  }
}
