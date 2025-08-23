import 'package:flutter/cupertino.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get pipNotAvailable;

  String get notifications;

  String get viewTheNewArrivals;

  String get clear;

  String get clearNotificationConfirmation;

  String get noNotificationsFound;

  String get skip;

  String get ago;

  String get justNow;

  String get blogs;

  String get leaveAReply;

  String get message;

  String get apply;

  String get protectedPostText;

  String get canNotViewPost;

  String get editComment;

  String get writeComment;

  String get commentUpdatedSuccessfully;

  String get deleteCommentConfirmation;

  String get tags;

  String get confirmYouWantToLeave;

  String get shareApp;

  String get reachUsMore;

  String get rateUs;

  String get loveItLetUsKnow;

  String get ourCommitmentToYour;

  String get streamNow;

  String get registerAndExploreOur;

  String get createYourAccountFor;

  String get youHaveBeenMissed;

  String get welcomeBack;

  String get profile;

  String get wooCommerce;

  String get pmpPayment;

  String get payment;

  String get products;

  String get orderStatus;

  String get orderNumber;

  String get viewOrdersOf;

  String get visaMastercard;

  String get africanMobilePayment;

  String get paymentBy;

  String get couponCode;

  String get discountAmount;

  String get enterCouponCode;

  String get noCouponsAvailable;

  String get applied;

  String get applyCoupon;

  String get appliedCoupon;

  String get cartDetails;

  String get subtotal;

  String get product;

  String get category;

  String get orderDetails;

  String get addRating;

  String get notFound;

  String get otherSettings;

  String get noDownloadsAvailable;

  String get youHavenTDownloadedAny;

  String get noCommentsAdded;

  String get letUsKnowWhat;

  String get contentAddedTo;

  String get willBeShownHere;

  String get isEmpty;

  String get detailsAreNotAvailable;

  String get noPlaylistsFoundFor;

  String get createPlaylistAndAdd;

  String get yourWatchListIsEmpty;

  String get keepTrackOfEverything;

  String get the;

  String get hasNotYetBeenAdded;

  String get content;

  String get found;

  String get reviewMembershipPlanAnd;

  String get theContentHasNot;

  String get noContentFound;

  String get currentDevice;

  String get model;

  String get deviceId;

  String get loginTime;

  String get areYouSureYouWantToLogOutFromThisDevice;

  String get continueWatching;

  String get manageDeviceText;

  String get manageDevices;

  String get youCanManageUnfamilier;

  String get signOutFromAllDevices;

  String get logOutAllDeviceConfirmation;

  String get manageAccount;

  String get lblPleaseRateUs;

  String get lbWaitForCommentApproval;

  String get lblRateAndReview;

  String get lblRating;

  String get lblAddYourReview;

  String get lblNoRatingsYet;

  String get ratings;

  String get viewMore;

  String get viewLess;

  String get description;

  String get failed;

  String get grantStoragePermissionTo;

  String get retry;

  String get editPlaylist;

  String get accountDeletedSuccessfully;

  String get watchYourNextList;

  String get playlists;

  String get membersOnly;

  String get thisContentIsFor;

  String get joinNow;

  String get alreadyAMember;

  String get youMustBeLogged;

  String get signUp;

  String get membershipExpiresAfter;

  String get noPlaylistsFound;

  String get selectPaymentMethod;

  String get endingWith;

  String get total;

  String get totalBilled;

  String get expiration;

  String get paymentMethod;

  String get accountHolderName;

  String get invoice;

  String get orderSummary;

  String get invoiceDetail;

  String get myAccount;

  String get myMemberships;

  String get selectAndProceed;

  String get yourPlan;

  String get membershipPlans;

  String get makePayment;

  String get checkout;

  String get confirmEmail;

  String get emailAddress;

  String get city;

  String get state;

  String get postalCode;

  String get country;

  String get phone;

  String get address2;

  String get address1;

  String get billingAddress;

  String get free;

  String get youHaveSelectedThe;

  String get accountDetails;

  String get pleaseEnterValidConfirmEmail;

  String get pastInvoices;

  String get viewAllInvoices;

  String get paid;

  String get amount;

  String get status;

  String get plan;

  String get chooseAMembershipPlan;

  String get youDontHaveMembership;

  String get edit;

  String get createPlaylist;

  String get playlist;

  String get deletePlaylist;

  String get areYouSureYouWantToDelete;

  String get createList;

  String get selectWhereYouWant;

  String get enterValidPlaylistName;

  String get playlistTitle;

  String get selectAnyPlaylist;

  String get addToPlaylist;

  String get saved;

  String get resume;

  String get startOver;

  String get doYouWishTo;

  String get resumeVideo;

  String get castDeviceList;

  String get notCloseCastScreen;

  String get refresh;

  String get noCastingDeviceFounded;

  String get cast;

  String get closeConnection;

  String get deviceDisconnectedSuccessfully;

  String get deviceConnectedSuccessfully;

  String get changePasswordText;

  String get watchVideosOffline;

  String get tapToSpeak;

  String get listening;

  String get danger;

  String get areYouSureYou;

  String get deleteAccount;

  String get downloadedVideos;

  String get deleteMovieSuccessfully;

  String get areYouSureYouWantDeleteThisMovie;

  String get delete;

  String get downloads;

  String get done;

  String get downloadSuccessfully;

  String get quality;

  String get player;

  String get date;

  String get links;

  String get sources;

  String get settings;

  String get dontHaveAnAccount;

  String get watchNow;

  String get signIn;

  String get somethingWantWrongPleaseContactYourAdministrator;

  String get writeSomething;

  String get commentAdded;

  String get sActing;

  String get addAComment;

  String get yourInterNetNotWorking;

  String get somethingWentWrong;

  String get thisFieldIsRequired;

  String get pleaseTryAgain;

  String get addReply;

  String get viewreply;

  String get readLess;

  String get readMore;

  String get noData;

  String get upgradePlan;

  String get subscribeNow;

  String get recommendedMovies;

  String get upcomingMovies;

  String get upcomingVideo;

  String get action;

  String get movies;

  String get tVShows;

  String get videos;

  String get home;

  String get more;

  String get membershipPlan;

  String get generalSettings;

  String get accountSettings;

  String get others;

  String get termsConditions;

  String get privacyPolicy;

  String get logOut;

  String get doYouWantToLogout;

  String get cancel;

  String get ok;

  String get search;

  String get searchMoviesTvShowsVideos;

  String get watchList;

  String get pleaseWait;

  String get addedToList;

  String get myList;

  String get changePassword;

  String get all;

  String get mostViewed;

  String get personalInfo;

  String get knownFor;

  String get knownCredits;

  String get placeOfBirth;

  String get alsoKnownAs;

  String get birthday;

  String get deathDay;

  String get password;

  String get newPassword;

  String get confirmPassword;

  String get bothPasswordShouldBeMatched;

  String get submit;

  String get changeAvatar;

  String get firstName;

  String get lastName;

  String get email;

  String get editProfile;

  String get save;

  String get viewInfo;

  String get loginNow;

  String get previous;

  String get next;

  String get trailerLink;

  String get runTime;

  String get episodes;

  String get loginToAddComment;

  String get views;

  String get starring;

  String get getStarted;

  String get login;

  String get forgotPassword;

  String get registerNow;

  String get enterValidEmail;

  String get forgotPasswordData;

  String get username;

  String get emailIsInvalid;

  String get passWordNotMatch;

  String get signUpNow;

  String get createAccount;

  String get signUpToDiscoverOurFeature;

  String get streamTermsConditions;

  String get back;

  String get jumanjiTheNextLevel;

  String get title;

  String get viewAll;

  String get language;

  String get selectTheme;

  String get as;

  String get validTill;

  String get resultFor;

  String get episode;

  String get likes;

  String get like;

  String get comments;

  String get comment;

  String get passwordLengthShouldBeMoreThan6;

  String get aboutUs;

  String get no;

  String get yes;

  String get profileHasBeenUpdatedSuccessfully;

  String get pleaseEnterPassword;

  String get pleaseEnterNewPassword;

  String get pleaseEnterConfirmPassword;

  String get pleaseEnterComment;

  String get genre;

  String get yourMembershipCancellationWill;

  String get noOfferingsFound;

  String get kindlyCancelTheCurrent;

  String get thisIsYourCurrent;

  String get revenueCatIdentifierMissMach;

  String get subscriptionDetailsRestored;

  String get update;

  String get rememberMe;

  String get youAreLoggedInLetsGetStarted;

  String get areYouSureYouWantToDeleteThisMovieFromDownloads;

  String get youHaveBeenLoggedOutFromThisDevice;

  String get demoUserCanTPerformThisAction;

  String get youHaveBeenLoggedOutSuccessfully;

  String get movieAddedToYourWatchlist;

  String get youHaveBeenSignedOutFromAllDevices;

  String get areYouSureYouWantToDeleteThisFromYourContinueWatching;

  String get editReview;

  String get editYourReview;

  String get areYouSureYouWantToDeleteThisReview;

  String get youHaveAlreadySubmittedReview;

  String get pleaseProvideRating;
  String get read;
  String get unRead;
  String get movieRemovedFromYourWatchlist;
  String get noGenresFound;
  String get noDataFound;
  String get pleaseLoginToSearch;
  String get pleaseEnterMessageBeforeSubmitting;
  String get yourCommentAddedSuccessfully;
  String get pleaseSelectRatingBeforeSubmittingYourReview;
  String get cannotUseOldPassword;
  String get movieDeletedSuccessfullyFromDownloads;
  String get videoUnavailable;
  String get videoUnavailableMessage;
  String get pleaseCheckLinkOrPrivacySettings;

  String get advertisement;

  String get skipAd;

  String get skipIn;

  String get live;

  String get tvGuide;

  String get liveTV;

  String get recommendedChannels;

  String get channelCategories;

  String get privacyLinkCheckMessage;

  String get liveStreamErrorMessage;

  String get videoNotFound;

  String get videoUnavailableTapToPlay;

  String get noProgram;

  String get noProgramsAvailable;

  String get yesterday;

  String get today;

  String get tomorrow;

  String get loginToWatchMessage;

  String get dayTime;

  String get channels;

  String get recommendedForYou;


  String get myRentals;

  String get manageRentals;

  String get validity;

  String get info;

  String get upgradeToWatch;

  String get subscribeToWatch;

  String get rentOrUpgradeToWatch;

  String get rentOrSubscribeToWatch;

  String get recommended;

  String get noRentalsFound;

  String get type;

  String get purchaseDate;

  String get expires;

  String get paymentStatus;

  String get totalAmount;

  String get day;

  String get days;

  String get rentFor;

  String get unpaid;

  String get rent;

  String get rented;

  String get paymentCompletedSuccessfully;

  String get checkoutUrlNotAvailable;

  String get lifetimeAccess;
}
