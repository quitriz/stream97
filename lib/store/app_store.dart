import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/local/app_localizations.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/resume_video_model.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';

import '../models/live_tv/live_channel_detail_model.dart';
import '../models/settings/settings_model.dart';
part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  String userNonce = '';

  @observable
  String wooNonce = '';

  @observable
  bool showItemName = false;

  @observable
  String? pmpCurrency = '';

  @observable
  String? currencySymbol = '';

  @observable
  bool showPIP = false;

  @observable
  bool isPIPOn = false;

  //region Continue Watch

  @observable
  var continueWatchList = ObservableList<ContinueWatchModel>();

  @action
  void addToWatchContinue(ContinueWatchModel data) =>
      continueWatchList.add(data);

  @action
  void removeFromWatchContinue(ContinueWatchModel data) =>
      continueWatchList.remove(data);

  @action
  void clearWatchContinue() => continueWatchList.clear();

  // end region

  //region User Details

  @observable
  String? loginDevice = '';

  @observable
  int? userId = getIntAsync(USER_ID);

  @observable
  String? userName = getStringAsync(USERNAME);

  @observable
  String? userEmail = getStringAsync(USER_EMAIL);

  @observable
  String? userProfileImage = getStringAsync(USER_PROFILE);

  @observable
  String? userFirstName = getStringAsync(NAME);

  @observable
  String? userLastName = getStringAsync(LAST_NAME);

  @observable
  bool isLoading = false;

  @observable
  String? appLogo = getStringAsync(APP_LOGO);

  @action
  Future<void> setShowItemName(bool val) async {
    showItemName = val;
  }

  @action
  Future<void> setWooNonce(String val) async {
    wooNonce = val;
    await setValue(WOO_NONCE, '$val');
  }

  @action
  Future<void> setUserNonce(String val) async {
    userNonce = val;
    await setValue(USER_NONCE, '$val');
  }

  @action
  Future<void> setPmpCurrency(String? currency) async {
    pmpCurrency = currency;
    await setValue(PMP_CURRENCY, currency);
  }

  @action
  Future<void> setCurrencySymbol(String? currency) async {
    currencySymbol = currency;
    await setValue(CURRENCY_SYMBOL, currency);
  }

  @action
  Future<void> setLoginDevice(String? deviceId) async {
    loginDevice = deviceId;
    await setValue(DEVICE_ID, deviceId);
  }

  @action
  Future<void> setUserId(int? id) async {
    userId = id;
    await setValue(USER_ID, id);
  }

  @action
  Future<void> setUserName(String? name) async {
    userName = name;
    await setValue(USERNAME, name);
  }

  @action
  Future<void> setUserEmail(String? value) async {
    userEmail = value;
    await setValue(USER_EMAIL, value);
  }

  @action
  Future<void> setUserProfile(String? image) async {
    userProfileImage = image;
    await setValue(USER_PROFILE, image);
  }

  @action
  Future<void> setFirstName(String? name) async {
    userFirstName = name;
    await setValue(NAME, name);
  }

  @action
  Future<void> setLastName(String? name) async {
    userLastName = name;
    await setValue(LAST_NAME, name);
  }

  @action
  Future<void> setEnableMembership(bool membership) async {
    isMembershipEnabled = membership;
    await setValue(IS_MEMBERSHIP_ENABLED, membership);
  }

  @action
  Future<void> setAppLogo(String? logo) async {
    appLogo = logo;
    await setValue(APP_LOGO, logo);
  }

  //endregion

  //region Subscription Plan Details
  @observable
  String subscriptionPlanId = "";

  @observable
  String subscriptionPlanStartDate = "";

  @observable
  String subscriptionPlanExpDate = "";

  @observable
  String subscriptionPlanStatus = "";

  @observable
  String subscriptionPlanTrialStatus = "";

  @observable
  String subscriptionPlanName = "";

  @observable
  String subscriptionPlanAmount = "";

  @observable
  String subscriptionTrialPlanEndDate = "";

  @observable
  String subscriptionTrialPlanStatus = "";

  @observable
  int downloadPercentage = 0;

  @observable
  bool hasErrorWhenDownload = false;

  @observable
  ObservableList<DownloadData> downloadedItemList =
      ObservableList.of(<DownloadData>[]);

  @observable
  bool isDownloading = false;

  @observable
  bool isTrailerVideoPlaying = false;

  @action
  void setTrailerVideoPlayer(bool value) {
    isTrailerVideoPlaying = value;
  }

  @action
  void setDownloading(bool val) {
    isDownloading = val;
  }

  @action
  void setDownloadError(bool val) {
    hasErrorWhenDownload = val;
  }

  @action
  void setDownloadPercentage(int val) {
    downloadPercentage = val;
  }

  @action
  Future<void> setSubscriptionPlanId(String id) async {
    subscriptionPlanId = id;
    await setValue(SUBSCRIPTION_PLAN_ID, id);
  }

  @action
  Future<void> setSubscriptionTrialPlanStatus(String trialStatus) async {
    subscriptionTrialPlanStatus = trialStatus;
    await setValue(SUBSCRIPTION_PLAN_TRIAL_STATUS, trialStatus);
  }

  @action
  Future<void> setSubscriptionPlanStartDate(String date) async {
    subscriptionPlanStartDate = date;
    await setValue(SUBSCRIPTION_PLAN_START_DATE, date);
  }

  @action
  Future<void> setSubscriptionPlanExpDate(String date) async {
    subscriptionPlanExpDate = date;
    await setValue(SUBSCRIPTION_PLAN_EXP_DATE, date);
  }

  @action
  Future<void> setSubscriptionPlanStatus(String status) async {
    subscriptionPlanStatus = status;
    await setValue(SUBSCRIPTION_PLAN_STATUS, status);
  }

  @action
  Future<void> setSubscriptionPlanName(String name) async {
    subscriptionPlanName = name;
    await setValue(SUBSCRIPTION_PLAN_NAME, name);
  }

  @action
  Future<void> setSubscriptionPlanAmount(String amount) async {
    subscriptionPlanAmount = amount;
    await setValue(SUBSCRIPTION_PLAN_AMOUNT, amount);
  }

  @action
  Future<void> setSubscriptionTrialPlanEndDate(String planEndDate) async {
    subscriptionTrialPlanEndDate = planEndDate;
    await setValue(SUBSCRIPTION_PLAN_TRIAL_END_DATE, planEndDate);
  }

  //endregion

  //region App setting
  @observable
  bool hasInFullScreen = false;

  @observable
  String selectedLanguageCode = defaultLanguage;

  @observable
  bool isLogging = false;

  @observable
  bool showAds = true;

  @observable
  bool showMovieComments = false;

  @observable
  bool showVideoComments = false;

  @observable
  bool showTVShowComments = false;

  @observable
  bool showEpisodeComment = false;

  @observable
  bool isMembershipEnabled = false;

  @observable
  int bottomNavigationCurrentIndex = 0;

  @observable
  SettingsModel? settings;

  @action
  Future<void> setSettings(SettingsModel settingsModel) async {
    settings = settingsModel;
    isLiveEnabled = settingsModel.isLiveEnabled ?? false;
    await setValue(IS_LIVE_STREAMING_ENABLED, isLiveEnabled);
  }

  @action
  void setAdsVisibility(bool val) {
    showAds = val;
  }

  @action
  Future<void> setLogging(bool value) async {
    isLogging = value;
    await setValue(isLoggedIn, value);
  }

  @action
  void setMovieTypeCommentsOnOff(bool val) {
    showMovieComments = val;
  }

  @action
  void setVideoTypeCommentsOnOff(bool val) {
    showVideoComments = val;
  }

  @action
  void setTVShowCommentsOnOff(bool val) {
    showTVShowComments = val;
  }

  @action
  void setEpisodeTypeCommentsOnOff(bool val) {
    showEpisodeComment = val;
  }

  @action
  Future<void> setToFullScreen(bool value) async {
    hasInFullScreen = value;
  }

  @action
  void setLoading(bool aIsLoading) {
    isLoading = aIsLoading;
  }

  @action
  void setPIPOn(bool value) {
    isPIPOn = value;
  }

  @action
  void setShowPIP(bool value) {
    showPIP = value;
  }

  @action
  Future<void> setLanguage(String val) async {
    selectedLanguageCode = val;
    selectedLanguageDataModel = getSelectedLanguageModel();

    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);

    language = await AppLocalizations().load(Locale(selectedLanguageCode));

    errorInternetNotAvailable = language.yourInterNetNotWorking;
    errorMessage = language.pleaseTryAgain;
    errorSomethingWentWrong = language.somethingWentWrong;
    errorThisFieldRequired = language.thisFieldIsRequired;
  }

  @action
  void setBottomNavigationIndex(int val) {
    bottomNavigationCurrentIndex = val;
  }

//endregion

  //region InApp Purchase
  @observable
  bool isInAppPurChaseEnable = false;

  @observable
  String filterType = FirebaseMsgConst.notificationTypeUnread;

  @observable
  String activeSubscriptionIdentifier =
      getStringAsync(SUBSCRIPTION_PLAN_IDENTIFIER);

  @observable
  String activeSubscriptionGoogleIdentifier =
      getStringAsync(SUBSCRIPTION_PLAN_GOOGLE_IDENTIFIER);

  @observable
  String activeSubscriptionAppleIdentifier =
      getStringAsync(SUBSCRIPTION_PLAN_APPLE_IDENTIFIER);

  @observable
  String inAppEntitlementID = getStringAsync(SUBSCRIPTION_ENTITLEMENT_ID);

  @observable
  String inAppGoogleApiKey = getStringAsync(SUBSCRIPTION_GOOGLE_API_KEY);

  @observable
  String inAppAppleApiKey = getStringAsync(SUBSCRIPTION_APPLE_API_KEY);

  @observable
  String wooConsumerKey = getStringAsync(SharePreferencesKey.WOO_CONSUMER_KEY);

  @observable
  String wooConsumerSecret =
      getStringAsync(SharePreferencesKey.WOO_CONSUMER_SECRET);

  @action
  Future<void> setWooConsumerKey(String val) async {
    wooConsumerKey = val;
    await setValue(SharePreferencesKey.WOO_CONSUMER_KEY, '$val', print: true);
  }

  @action
  Future<void> setWooConsumerSecret(String val) async {
    wooConsumerSecret = val;
    await setValue(SharePreferencesKey.WOO_CONSUMER_SECRET, '$val',
        print: true);
  }

  Future<void> setInAppPurchaseAvailable(bool value) async {
    isInAppPurChaseEnable = value;
    setValue(HAS_IN_APP_PURCHASE_ENABLE, value);
  }

  Future<void> setActiveSubscriptionIdentifier(String value) async {
    activeSubscriptionIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_IDENTIFIER, value);
  }

  Future<void> setActiveSubscriptionGoogleIdentifier(String value) async {
    activeSubscriptionGoogleIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_GOOGLE_IDENTIFIER, value);
  }

  Future<void> setActiveSubscriptionAppleIdentifier(String value) async {
    activeSubscriptionAppleIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_APPLE_IDENTIFIER, value);
  }

  @action
  Future<void> setInAppEntitlementID(String val) async {
    inAppEntitlementID = val;
    await setValue(SUBSCRIPTION_ENTITLEMENT_ID, '$val', print: true);
  }

  @action
  Future<void> setInAppGoogleApiKey(String val) async {
    inAppGoogleApiKey = val;
    await setValue(SUBSCRIPTION_GOOGLE_API_KEY, '$val', print: true);
  }

  @action
  Future<void> setInAppAppleApiKey(String val) async {
    inAppAppleApiKey = val;
    await setValue(SUBSCRIPTION_APPLE_API_KEY, '$val', print: true);
  }

  @observable
  bool doRemember = false;

  @action
  Future<void> setRemember(bool val) async {
    doRemember = val;
    await setValue('REMEMBER_ME', val);
  }

  @observable
  ObservableList<ReviewModel> reviewList = ObservableList<ReviewModel>();

//endregion

//region Live Streaming

  @observable
  bool isLiveEnabled = false;

  @action
  Future<void> setEnableLiveStreaming(bool liveStreaming) async {
    isLiveEnabled = liveStreaming;
    await setValue(IS_LIVE_STREAMING_ENABLED, liveStreaming);
  }

  @observable
  LiveChannelDetails? liveChannelDetails;

}
