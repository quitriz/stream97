import 'package:nb_utils/nb_utils.dart';
const app_name = "STREAMIT";

const walk_titles = ["Watch On Any Devices ", "Download And Go ", "No Pesky Contract"];

const walk_sub_titles = [
  "Stream On Your Phone, Tablet, Laptop And TV Without Paying More",
  "Save Your Data, Watch Offline On A Plane, Train or Submarine",
  "Join Today, Cancel Anytime & No Extra Charges Contain",
];

const IOS_APP_LINK = '';

/// NOTE: Do not add slash (/) at the end of your domain.
const mDomainUrl = "YOUR_DOMAIN_URL";


const mBaseUrl = '$mDomainUrl/wp-json/';

const aboutUsURL = "$mDomainUrl/about-us/";
const termsConditionURL = "$mDomainUrl/terms-and-use/";
const privacyPolicyURL = "$mDomainUrl/privacy-policy/";

// google ads ID's
final mAdMobAppId =  isIOS ? 'YOUR_IOS_APP_ID' :'YOUR_ANDROID_APP_ID';
final mAdMobBannerId = isIOS ? 'YOUR_IOS_BANNER_ID' : 'YOUR_ANDROID_BANNER_ID';
final mAdMobInterstitialId =  isIOS ? 'YOUR_IOS_INTERSTITIAL_ID' : 'YOUR_ANDROID_INTERSTITIAL_ID';

/// enable and disable AdS
const disabledAds =false;

/// Default app language
const defaultLanguage = 'en';