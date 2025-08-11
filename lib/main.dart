import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/local/app_localizations.dart';
import 'package:streamit_flutter/local/base_language.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/splash_screen.dart';
import 'package:streamit_flutter/store/app_store.dart';
import 'package:streamit_flutter/store/epg_store.dart';
import 'package:streamit_flutter/store/user_store.dart';
import 'package:streamit_flutter/utils/app_theme.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: defaultFirebaseOption());
  log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
  log('${FirebaseMsgConst.notificationKey} : ${message.notification}');
  log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
  log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
}

AppStore appStore = AppStore();
UserStore userStore = UserStore();
EPGStore epgStore = EPGStore();

bool mIsLoggedIn = false;
int adShowCount = 0;
BaseLanguage? language;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: isIOS ? null : defaultFirebaseOption()).then((value) {
    if (!isWeb) {
      PushNotificationService().initFirebaseMessaging();
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }).catchError((e) {
    log("firebase error : ====> ${e.toString()}");
  });

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  if (isMobile)
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  else if (!isWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  await initialize(aLocaleLanguageList: languageList());

  await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));

  textPrimaryColorGlobal = Colors.white;
  textSecondaryColorGlobal = Colors.grey.shade500;

  appStore.setUserName(getStringAsync(USERNAME));
  appStore.setUserId(getIntAsync(USER_ID));
  appStore.setUserEmail(getStringAsync(USER_EMAIL));
  if (getStringAsync(USER_PROFILE).isNotEmpty) {
    appStore.setUserProfile(getStringAsync(USER_PROFILE));
  } else {
    appStore.setUserProfile(userProfileImage());
  }
  appStore.setFirstName(getStringAsync(NAME));
  appStore.setLastName(getStringAsync(LAST_NAME));
  appStore.setLogging(getBoolAsync(isLoggedIn));
  appStore.setLoginDevice(getStringAsync(DEVICE_ID));
  appStore.setPmpCurrency(getStringAsync(PMP_CURRENCY));
  appStore.setCurrencySymbol(getStringAsync(CURRENCY_SYMBOL));
  appStore.setWooNonce(getStringAsync(WOO_NONCE));
  appStore.setUserNonce(getStringAsync(USER_NONCE));
  appStore.setEnableMembership(getBoolAsync(IS_MEMBERSHIP_ENABLED));
  appStore.setInAppPurchaseAvailable(getBoolAsync(HAS_IN_APP_PURCHASE_ENABLE));
  appStore.setSubscriptionPlanId(getStringAsync(SUBSCRIPTION_PLAN_ID));
  appStore.setSubscriptionPlanStatus(getStringAsync(SUBSCRIPTION_PLAN_STATUS));
  appStore.setSubscriptionPlanAmount(getStringAsync(SUBSCRIPTION_PLAN_AMOUNT));
  appStore.setActiveSubscriptionAppleIdentifier(getStringAsync(SUBSCRIPTION_PLAN_APPLE_IDENTIFIER));
  appStore.setActiveSubscriptionGoogleIdentifier(getStringAsync(SUBSCRIPTION_PLAN_GOOGLE_IDENTIFIER));
  appStore.setActiveSubscriptionIdentifier(getStringAsync(SUBSCRIPTION_PLAN_IDENTIFIER));
  appStore.setInAppEntitlementID(getStringAsync(SUBSCRIPTION_ENTITLEMENT_ID));
  appStore.setInAppGoogleApiKey(getStringAsync(SUBSCRIPTION_GOOGLE_API_KEY));
  appStore.setInAppAppleApiKey(getStringAsync(SUBSCRIPTION_APPLE_API_KEY));
  appStore.setRemember(getBoolAsync(SharePreferencesKey.REMEMBER_ME));
  appStore.setAppLogo(getStringAsync(APP_LOGO));

  setOrientationPortrait();

  defaultAppButtonRadius = 8;

  if (mAdMobAppId.isNotEmpty) _initGoogleMobileAds();

  runApp(MyApp());
}

Future<InitializationStatus> _initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          HomeScreen.tag: (BuildContext context) => HomeScreen(),
        },
        builder: scrollBehaviour(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
      ),
    );
  }
}
