import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/auth/edit_profile_response.dart';
import 'package:streamit_flutter/models/auth/nonce_model.dart';
import 'package:streamit_flutter/models/blog/wp_comments_model.dart';
import 'package:streamit_flutter/models/blog/wp_post_response.dart';
import 'package:streamit_flutter/models/common/base_response.dart';
import 'package:streamit_flutter/models/live_tv/epg_data_model.dart';
import 'package:streamit_flutter/models/live_tv/live_category_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/cast_model.dart';
import 'package:streamit_flutter/models/movie_episode/comment_model.dart';
import 'package:streamit_flutter/models/dashboard_response.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/models/movie_episode/season_detail_model.dart';
import 'package:streamit_flutter/models/notification_model.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';
import 'package:streamit_flutter/models/settings/settings_model.dart';
import 'package:streamit_flutter/models/auth/validate_token_model.dart';
import 'package:streamit_flutter/models/view_all_response.dart';
import 'package:streamit_flutter/models/pmp_models/pmp_order_model.dart';
import 'package:streamit_flutter/models/watchlist_response.dart';
import 'package:streamit_flutter/models/woo_commerce/order_model.dart';
import 'package:streamit_flutter/models/woo_commerce/product_model.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/push_notification_service.dart';

import '../models/live_tv/live_channel_detail_model.dart';
import '../screens/home_screen.dart';
import '../utils/cached_data.dart';
import 'network_utils.dart';

//region Auth

Future<LoginResponse> token(Map request) async {
  PushNotificationService().registerFCMAndTopics();
  LoginResponse res = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, body: request, aAuthRequired: false, method: HttpMethod.POST)));

  await setValue(TOKEN, res.token);

  Map<String, dynamic>? decodedToken = JwtDecoder.decode(getStringAsync(TOKEN));
  await setValue(EXPIRATION_TOKEN_TIME, decodedToken?['exp']);

  await setUserData(logRes: res);

  await setValue(isLoggedIn, true);
  mIsLoggedIn = true;
  manageFirebaseToken();

  PushNotificationService().registerFCMAndTopics();
  if (appStore.isInAppPurChaseEnable) await InAppPurchaseService.init();
  return res;
}

Future<void> manageFirebaseToken() async {
  Map<String, dynamic> req = {FirebaseMsgConst.firebaseToken: getStringAsync(FIREBASE_TOKEN)};
  log("Firebase token------------token-------${getStringAsync(FIREBASE_TOKEN)}");
  await handleResponse(await buildHttpResponse(APIEndPoint.manageFirebaseToken, method: HttpMethod.POST, body: req)).onError((error, stackTrace) {
    log('Manage-Firebase-Token-Error ${error.toString()}');
  });
}

Future<void> logout({bool logoutFromAll = false, bool isNewTask = false, BuildContext? context}) async {
  appStore.setLoading(true);
  if (await isNetworkAvailable()) {
    if (getStringAsync(TOKEN).isNotEmpty) {
      Map request = {"device_id": appStore.loginDevice, FirebaseMsgConst.firebaseToken: getStringAsync(FIREBASE_TOKEN)};
      await deleteDevice(request).then((value) {
        logoutFromAll ? toast(language.youHaveBeenSignedOutFromAllDevices) : Offstage();
      }).catchError(onError);
    }
    await PushNotificationService().unsubscribeFirebaseTopic();
    removeKey(TOKEN);
    removeKey(FIREBASE_TOKEN);
    removeKey(HAS_IN_APP_SDK_INITIALISE_AT_LEASE_ONCE);

    appStore.setFirstName('');
    appStore.setLastName('');
    appStore.setUserProfile('');
    appStore.setLoginDevice('');
    appStore.setLogging(false);
    appStore.setLoading(false);

    if (isNewTask) {
      appStore.setBottomNavigationIndex(0);
      HomeScreen().launch(context ?? getContext, isNewTask: true);
    }

    appStore.setUserId(null);
    appStore.setUserName('');
    appStore.setUserEmail('');

    appStore.setSubscriptionPlanId("");
    appStore.setSubscriptionPlanStartDate("");
    appStore.setSubscriptionPlanExpDate("");
    appStore.setSubscriptionPlanStatus("");
    appStore.setSubscriptionPlanName("");
    appStore.setSubscriptionPlanAmount("");
    appStore.setSubscriptionTrialPlanStatus("");
    appStore.setSubscriptionTrialPlanEndDate("");
    appStore.setActiveSubscriptionIdentifier('');
    appStore.setActiveSubscriptionGoogleIdentifier('');
    appStore.setActiveSubscriptionAppleIdentifier('');

    setValue(isFirstTime, false);
    setValue(isLoggedIn, false);
    mIsLoggedIn = false;

    appStore.setLogging(false);

    if (isIOS) {
      await getApplicationDocumentsDirectory().then((value) async {
        if (value.existsSync()) {
          value.deleteSync(recursive: true);
          await removeKey(DOWNLOADED_DATA);
        }
      });
    } else {
      await getDownloadsDirectory().then((value) async {
        if (value != null && value.existsSync()) {
          value.deleteSync(recursive: true);
          await removeKey(DOWNLOADED_DATA);
        }
      });
    }

    appStore.downloadedItemList.clear();
  } else {
    toast(errorInternetNotAvailable);
  }
}

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.forgotPassword, body: request, aAuthRequired: false, method: HttpMethod.POST))));
}

Future register(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoint.registration, body: request, aAuthRequired: false, method: HttpMethod.POST));
}

Future<ValidateTokenModel> validateToken({required String deviceId}) async {
  Map request = {"device_id": deviceId};
  return ValidateTokenModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.validateToken, body: request, method: HttpMethod.POST))));
}

Future<BaseResponseModel> changePassword(Map request) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.changePassword, body: request, method: HttpMethod.POST))));
}

Future<LoginResponse> getUserProfileDetails() async {
  return LoginResponse.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.profile))));
}

Future<void> addDevices(Map request) async {
  return await (handleResponse(await buildHttpResponse(APIEndPoint.devices, body: request, method: HttpMethod.POST)));
}

Future<dynamic> getDevices() async {
  return await (handleResponse(await buildHttpResponse(APIEndPoint.devices)));
}

Future<void> deleteDevice(Map request) async {
  return await (handleResponse(await buildHttpResponse(APIEndPoint.devices, body: request, method: HttpMethod.DELETE)));
}

Future<void> deleteUserAccount() async {
  await handleResponse(await buildHttpResponse(APIEndPoint.deleteAccount, aAuthRequired: true, method: HttpMethod.DELETE));
}

Future<void> updateProfile({required String firstName, required String latName, XFile? image}) async {
  if (await isNetworkAvailable()) {
    appStore.setLoading(true);
    var multiPartRequest = await postMultiPartRequest(APIEndPoint.profile);
    multiPartRequest.fields['first_name'] = firstName;
    multiPartRequest.fields['last_name'] = latName;
    if (image != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', image.path));

    multiPartRequest.headers.addAll(await buildTokenHeader());

    log(multiPartRequest.fields.toString());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        toast(language.profileHasBeenUpdatedSuccessfully);
        Map<String, dynamic> res = jsonDecode(data);
        log(res);
        if (res['status']) {
          EditProfileResponse profile = EditProfileResponse.fromJson(res['data']);

          appStore.setFirstName(profile.firstName);
          appStore.setLastName(profile.lastName);

          if (profile.profileImage != null && profile.profileImage.validate().isNotEmpty) {
            appStore.setUserProfile(profile.profileImage);
          }
        } else {
          toast(res['message']);
        }

        appStore.setLoading(false);
      },
      onError: (error) {
        appStore.setLoading(false);
        log('error: ${error.toString()}');
      },
    );
  }
}

Future<NonceModel> getNonce({required String type}) async {
  return NonceModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.authNonce}?nonce_for=$type', method: HttpMethod.POST))));
}

Future<SettingsModel> getSettings() async {
  SettingsModel value = SettingsModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.settings)));
  await appStore.setWooConsumerKey(parseHtmlString(value.wooConsumerKey.validate()));
  await appStore.setWooConsumerSecret(parseHtmlString(value.wooConsumerSecret.validate()));
  await appStore.setEnableLiveStreaming(value.isLiveEnabled ?? false);
  return value;
}

//endregion

//region Details
Future<DashboardResponse> getDashboardData(Map request, {String type = dashboardTypeHome}) async {
  var res = DashboardResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoint.dashboard}/$type',
      body: request,
      aAuthRequired: appStore.isLogging ? true : false,
    ),
  ));

  return res;
}

Future<List<CommonDataListModel>> searchMovie(String aSearchText, {int page = 1, required List<CommonDataListModel> movies, bool isLoading = true}) async {
  appStore.setLoading(isLoading);

  try {
    Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.search}?search=$aSearchText&user_id=${appStore.userId}&paged=$page&posts_per_page=$postPerPage')));

    if (page == 1) movies.clear();

    if (it.validate().isNotEmpty) {
      movies.addAll(it.map((e) => CommonDataListModel.fromJson(e)).toList());
    }
  } catch (e) {
    throw e;
  } finally {
    appStore.setLoading(false);
  }

  return movies;
}

Future<List<RecentSearchListModel>> recentListFetch({int page = 1, required List<RecentSearchListModel> recentList, bool isLoading = true}) async {
  appStore.setLoading(isLoading);

  try {
    Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchList}?user_id=${appStore.userId}')));

    if (page == 1) recentList.clear();

    if (it.validate().isNotEmpty) {
      recentList.addAll(it.map((e) => RecentSearchListModel.fromJson(e)).toList());
    }
  } catch (e) {
    throw e;
  } finally {
    appStore.setLoading(false);
  }

  return recentList;
}

Future<BaseResponseModel> addRecent(String title) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchAdd}?search=$title', method: HttpMethod.POST))));
}

Future<BaseResponseModel> removeRecent(int id) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchRemove}?id=$id', method: HttpMethod.POST))));
}

Future<ViewAllResponse> viewAll(int index, String type, {int page = 1, List<dynamic>? list = const [], PostType postType = PostType.MOVIE}) async {
  final queryParams = {'post_type': postType.name.toLowerCase(), 'filter': type, 'paged': page.toString(), 'posts_per_page': postPerPage.toString()};

  if (list != null && list.isNotEmpty) {
    queryParams[type] = list.join(',');
  }

  final uri = Uri.parse(APIEndPoint.viewAll).replace(queryParameters: queryParams);
  final rawResponse = await buildHttpResponse(uri.toString());

  final response = await handleResponse(rawResponse, responseType: ResponseType.FULL_RESPONSE);
  final responseBody = json.decode(response.body);

  if (responseBody is Map<String, dynamic>) {
    return ViewAllResponse.fromJson(responseBody);
  } else if (responseBody is List) {
    throw Exception("Unexpected list response: Expected a JSON object.");
  } else {
    throw Exception("Invalid response structure.");
  }
}

Future<MovieDetailResponse> movieDetail(int aId) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.movieDetails}/$aId'));
  final details = response['details'];
  final adConfig = response['ad_configuration'];
  if (details is Map<String, dynamic>) {
    details['ad_configuration'] = adConfig;
  }
  return MovieDetailResponse.fromJson({
    'details': details,
    'recommended_movies': response['recommended_movies'],
    'upcoming_movies': response['upcoming_movies'],
    'upcoming_videos': response['upcoming_videos'],
  });
}

Future<MovieDetailResponse> tvShowDetail(int aId) async {
  return MovieDetailResponse.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.tvShowDetails}/$aId'))));
}

Future<Season> tvShowSeasonDetail({required int showId, required int seasonId, int page = 1}) async {
  return Season.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.tvShowDetails}/$showId/seasons/$seasonId?page=$page&posts_per_page=$postPerPage'))));
}

Future<MovieDetailResponse> episodeDetail(int? aId) async {
  return MovieDetailResponse.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.episodeDetails}/$aId?user_id=${appStore.userId}'))));
}

Future<MovieData> getEpisodeDetail(int? aId) async {
  final httpResponse = await buildHttpResponse('${APIEndPoint.episodeDetails}/$aId?user_id=${appStore.userId}');
  final fullResponse = jsonDecode(httpResponse.body);
  final adConfig = fullResponse['ad_configuration'];
  final response = await handleResponse(httpResponse);
  final details = Map<String, dynamic>.from(response);
  details['ad_configuration'] = adConfig;
  return MovieData.fromJson(details);
}

Future<MovieDetailResponse> getVideosDetail(int id) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.videoDetails}/$id'));
  final details = response['details'];
  final adConfig = response['ad_configuration'];
  if (details is Map<String, dynamic>) {
    details['ad_configuration'] = adConfig;
  }
  return MovieDetailResponse.fromJson({
    'details': details,
    'recommended_movies': response['recommended_movies'],
    'upcoming_movies': response['upcoming_movies'],
    'upcoming_videos': response['upcoming_videos'],
  });
}

Future<LikeAndWatchListResponse> likeMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.like, body: request, method: HttpMethod.POST))));
}

Future<List<CommonDataListModel>> getWatchList({int page = 1}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.watchlist}?posts_per_page=$postPerPage&page=$page', aAuthRequired: true)));

  return it.map((e) => CommonDataListModel.fromJson(e)).toList();
}

Future<LikeAndWatchListResponse> watchlistMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.watchlist, body: request, method: HttpMethod.POST))));
}

Future<List<CommentModel>> getComments({int? postId, int? page, int? commentPerPage}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.wpComments}?post=$postId&page=$page&per_page=$commentPerPage&order=desc', aAuthRequired: true)));
  return it.map((e) => CommentModel.fromJson(e)).toList();
}

Future<List<ReviewModel>> getReviewList({required String postType, required int? postId}) async {
  Iterable it = await handleResponse(
    await buildHttpResponse('${APIEndPoint.rate}/$postType/$postId', method: HttpMethod.GET),
  );
  return it.map((e) => ReviewModel.fromJson(e)).toList();
}

Future<BaseResponseModel> addReview(Map request, String type, {String? method = ''}) async {
  return BaseResponseModel.fromJson(
      await (handleResponse(await buildHttpResponse('${APIEndPoint.rate}/$type', body: request, method: method == 'delete' ? HttpMethod.DELETE : HttpMethod.POST))));
}

Future<CommentModel> addComment(Map request) async {
  return CommentModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.wpComments, body: request, method: HttpMethod.POST))));
}

Future<CastModel> getCastDetails(String castId) async {
  return CastModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.personDetails}/$castId')));
}

Future<List<CommonDataListModel>> getCastMovieTvShowList({String? type = '', int? castId, int? page}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.personDetails}/$castId/work-history?type=$type&posts_per_page=$postPerPage&paged=$page')));
  return it.map((e) => CommonDataListModel.fromJson(e)).toList();
}

Future<List<GenreData>> getGenreList({
  int? page = 1,
  String? type = dashboardTypeMovie,
  required List<GenreData> genreDataList,
  Function(bool)? lastPageCallback,
  bool isLast = false,
}) async {
  try {
    GenreResponse genreResponse = GenreResponse.fromJson(await handleResponse(
      await buildHttpResponse('${APIEndPoint.genre}/$type/genre?paged=$page&posts_per_page=16'),
      isGenre: true,
    ));

    if (page == 1) genreDataList.clear();

    lastPageCallback?.call(genreResponse.genreDataList.validate().length != postPerPage);
    genreDataList.addAll(genreResponse.genreDataList.validate());

    if (page == 1) {
      GenreCachedData.storeData(genreTypeKey: type.validate(), data: genreDataList.map((e) => e.toJson()).toList());
    }
    appStore.setLoading(false);
    return genreDataList;
  } catch (e) {
    appStore.setLoading(false);
    log(e.toString());
    toast(e.toString());
    return [];
  }
}

Future<List<CommonDataListModel>> getMovieListByGenre(String genre, String type, int page) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.genre}/$type/genre/$genre?paged=$page&posts_per_page=$postPerPage')));
  return it.map((e) => CommonDataListModel.fromJson(e)).toList();
}

Future<void> saveVideoContinueWatch({
  required int postId,
  required int watchedTime,
  required int watchedTotalTime,
  required PostType postType,
}) async {
  Map request = {
    "post_id": postId,
    "watched_time": watchedTime,
    "watched_total_time": watchedTotalTime,
    'post_type': postType.name.toLowerCase(),
  };
  await handleResponse(
    await buildHttpResponse(
      APIEndPoint.continueWatch,
      body: request,
      aAuthRequired: true,
      method: HttpMethod.POST,
    ),
  );
}

Future<List<CommonDataListModel>> getVideoContinueWatch({
  int? page = 1,
  String type = '',
  required List<CommonDataListModel> continueWatchList,
  Function(bool)? lastPageCallback,
}) async {
  List<String> params = [];
  params.add('page=${page}');
  params.add('per_page=${postPerPage}');
  if (type.isNotEmpty) params.add('post_type=${type}');

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.continueWatch}?${params.join('&')}', aAuthRequired: true));

  if (page == 1) continueWatchList.clear();

  lastPageCallback?.call(it.length < postPerPage);
  continueWatchList.addAll(it.map((e) => CommonDataListModel.fromJson(e)).toList());

  return continueWatchList;
}

Future<void> deleteVideoContinueWatch({required int postId, required PostType postType}) async {
  Map request = {"post_id": postId, 'post_type': postType.name.toLowerCase()};
  await handleResponse(await buildHttpResponse(APIEndPoint.continueWatch, body: request, aAuthRequired: true, method: HttpMethod.DELETE));
}

//endregion

//region Playlist
Future<BaseResponseModel> createOrEditPlaylist({required Map request, String type = playlistMovie}) async {
  log('Request : $request');

  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.playlist}/$type', body: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deletePlaylist({required Map request, String type = playlistMovie}) async {
  log('request : $request');

  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.playlist}/$type', body: request, method: HttpMethod.DELETE)));
}

// add and delete edit items to playlist
Future<BaseResponseModel> editPlaylistItems({required Map request, String type = playlistMovie, required int playListId, required isDelete}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(
    '${APIEndPoint.playlist}/$type/$playListId',
    body: request,
    method: isDelete ? HttpMethod.DELETE : HttpMethod.POST,
  )));
}

Future<List<PlaylistModel>> getPlayListByType({String type = playlistMovie, int? postId}) async {
  Response response = await buildHttpResponse(
    '${APIEndPoint.playlist}/$type${postId != null ? '?post_id=$postId' : ''}',
    aAuthRequired: true,
  );

  // Check if the response is a list or a map
  final jsonData = jsonDecode(response.body);

  if (jsonData is List) {
    return jsonData.map((item) => PlaylistModel.fromJson(item)).toList();
  } else if (jsonData is Map<String, dynamic>) {
    PlaylistResp playList = PlaylistResp.fromJson(jsonData);
    return playList.data;
  } else {
    throw Exception('Unexpected response format');
  }
}

Future<List<CommonDataListModel>> getPlayListMedia({
  required int playlistId,
  required String postType,
  int page = 1,
}) async {
  final response = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoint.playlist}/$postType/$playlistId?posts_per_page=7&page=$page',
      aAuthRequired: true,
    ),
  );

  // Handle null or non-iterable responses gracefully
  if (response == null) {
    return <CommonDataListModel>[]; // Return an empty list if the response is null
  }

  try {
    // Ensure the response is an iterable or handle unexpected formats
    Iterable it = response as Iterable? ?? [];
    return it.map((e) => CommonDataListModel.fromJson(e)).toList();
  } catch (error) {
    return <CommonDataListModel>[]; // Return an empty list on parsing failure
  }
}

//endregion

//region PMP
Future<dynamic> getMembershipLevelForUser({required int userId}) async {
  var value = await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.getMembershipLevelForUser}?user_id=$userId', aAuthRequired: true));

  if (value == false) {
    return null;
  } else {
    MembershipModel membership = MembershipModel.fromJson(value);

    appStore.setSubscriptionPlanStatus(userPlanStatus);
    appStore.setSubscriptionPlanName(membership.name.validate());
    appStore.setSubscriptionPlanId(membership.id.validate());
    appStore.setSubscriptionPlanExpDate(membership.enddate.validate().toString());
    appStore.setSubscriptionPlanId(membership.id.validate());
    appStore.setSubscriptionPlanStartDate(membership.startdate.validate());
    if (membership.enddate.validate() > 0) appStore.setSubscriptionPlanExpDate(DateFormat(defaultDateFormat).format(DateTime.fromMillisecondsSinceEpoch(membership.enddate.validate())));
    appStore.setSubscriptionPlanName(membership.name.validate());
    appStore.setSubscriptionPlanAmount(membership.billingAmount.validate().toString());

    if (appStore.isInAppPurChaseEnable) {
      appStore.setActiveSubscriptionIdentifier(isIOS ? membership.appStorePlanIdentifier.validate() : membership.playStorePlanIdentifier.validate());
      appStore.setActiveSubscriptionAppleIdentifier(membership.appStorePlanIdentifier.validate());
      appStore.setActiveSubscriptionGoogleIdentifier(membership.playStorePlanIdentifier.validate());
    }

    return value;
  }
}

Future<List<MembershipModel>> getLevelsList({int? postId, int? page, int? commentPerPage}) async {
  Iterable it = await (handleResponse(await buildHttpResponse(MembershipAPIEndPoint.membershipLevels, aAuthRequired: true)));
  return it.map((e) => MembershipModel.fromJson(e)).toList();
}

Future<List<PmpOrderModel>> pmpOrders({int page = 1}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.membershipOrders}?page=$page&per_page=20', aAuthRequired: true)));
  return it.map((e) => PmpOrderModel.fromJson(e)).toList();
}

Future<PayPerViewOrdersModel> getPpvOrders({int page = 1}) async {
  final response = await buildHttpResponse('${MembershipAPIEndPoint.payPerViewOrders}?page=$page&per_page=$postPerPage', aAuthRequired: true);
  final fullResponse = await handleResponse(response, responseType: ResponseType.FULL_RESPONSE);
  return PayPerViewOrdersModel.fromJson(json.decode(fullResponse.body));
}

Future<void> cancelMembershipLevel({String? levelId}) async {
  String level = levelId == null ? "" : "&level_id=$levelId";
  await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.cancelMembershipLevel}?user_id=${appStore.userId}$level', method: HttpMethod.POST));
}

Future<PmpOrderModel> generateInAppOrder(Map request) async {
  return PmpOrderModel.fromJson(await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.membershipOrders}', body: request, method: HttpMethod.POST)));
}

Future<void> changeMembershipLevel({required String levelId}) async {
  await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.changeMembershipLevel}?user_id=${appStore.userId}&level_id=$levelId', method: HttpMethod.POST));
}

//endregion

//region Woo Commerce

Future<ProductModel> productDetail({required int productID}) async {
  return ProductModel.fromJson(
      await (handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.wcProducts}/$productID', isForWoocommerce: true, requiredNonce: true, aAuthRequired: false))));
}

Future<OrderModel> createOrders({required Map request}) async {
  return OrderModel.fromJson(await handleResponse(await buildHttpResponse(
    MembershipAPIEndPoint.wcOrders,
    body: request,
    requiredNonce: true,
    aAuthRequired: false,
    isForWoocommerce: true,
    method: HttpMethod.POST,
  )));
}

Future<OrderModel> getOrderDetail({required int id}) async {
  return OrderModel.fromJson(await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.wcOrders}/$id', requiredNonce: true, aAuthRequired: false, isForWoocommerce: true)));
}

Future<List<OrderModel>> getOrderList({int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.wcOrders}?customer=${appStore.userId}&page=$page&per_page=$postPerPage',
      requiredNonce: true, aAuthRequired: false, isForWoocommerce: true));

  return it.map((e) => OrderModel.fromJson(e)).toList();
}
//endregion

//region blogs
Future<List<WpPostResponse>> getBlogList({int? page, String? searchText}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.wpPost}?_embed&page=$page&per_page=$postPerPage&search=$searchText', method: HttpMethod.GET));
  return it.map((e) => WpPostResponse.fromJson(e)).toList();
}

Future<List<WpCommentModel>> getBlogComments({int? id, int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.wpComments}?post=$id&order=asc&page=$page&per_page=$postPerPage', method: HttpMethod.GET));
  return it.map((e) => WpCommentModel.fromJson(e)).toList();
}

Future<WpCommentModel> addBlogComment({required int postId, String? content, int? parentId}) async {
  Map request = {"post": postId, "content": content, "parent": parentId};
  return WpCommentModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.wpComments}', method: HttpMethod.POST, body: request)));
}

Future<BaseResponseModel> deleteBlogComment({required int commentId}) async {
  Map request = {"id": commentId};
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.blogComment}', method: HttpMethod.DELETE, body: request)));
}

Future<WpCommentModel> updateBlogComment({required int commentId, String? content}) async {
  Map request = {"id": commentId, "content": content};
  return WpCommentModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.blogComment}', method: HttpMethod.POST, body: request)));
}

Future<WpPostResponse> wpPostById({required int postId, String? password}) async {
  return WpPostResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.wpPost}/$postId?_embed${password.validate().isNotEmpty ? '&password=$password' : ''}')));
}

//endregion

//region notifications

Future<List<NotificationModel>> getNotifications({int page = 1, String type = ""}) async {
  String filterType = type.isEmpty ? "" : "/$type";
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getNotificationsList}$filterType?page=$page&per_page=$postPerPage', method: HttpMethod.GET));
  return it.map((e) => NotificationModel.fromJson(e)).toList();
}

Future<BaseResponseModel> readNotificationAdd(String id) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.notificationsReadAdd}/$id', method: HttpMethod.POST))));
}

Future<BaseResponseModel> clearNotification() async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.clearNotification, method: HttpMethod.DELETE)));
}

Future<NotificationCount> notificationCount() async {
  return NotificationCount.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.notificationCount, method: HttpMethod.GET)));
}

//endregion
//region live channel

Future<LiveChannelDetails> getLiveChannelDetails({required int channelId}) async {
  final response = await handleResponse(await buildHttpResponse("${APIEndPoint.liveChannelDetail}/$channelId", method: HttpMethod.GET));
  final details = response['details'];
  final recommended = response['recommended_channels'];
  final adConfig = response['ad_configuration'];

  if (details is Map<String, dynamic>) {
    return LiveChannelDetails.fromJson({...details, 'recommended_channels': recommended, 'ad_configuration': adConfig});
  } else {
    throw Exception('Invalid or missing "details" in API response');
  }
}

Future<EpgDataModel> getEPGData({required String date, required int channelId}) async {
  final cacheKey = 'epg_${channelId}_$date';
  // Try to get from cache first
  final cached = CachedData.getCachedData(cachedKey: cacheKey);
  if (cached != null) {
    return EpgDataModel.fromJson(cached);
  }
  final deviceTimezone = DateTime.now().timeZoneName;
  final response = await buildHttpResponse('${APIEndPoint.epgDetail}/$channelId?date=$date&timezone=$deviceTimezone', method: HttpMethod.GET);
  final decoded = await handleResponse(response);
  // Store in cache for future use
  await setValue(cacheKey, jsonEncode(decoded));
  return EpgDataModel.fromJson(decoded);
}

Future<AllLiveCategoryList> getLiveCategoryList() async {
  final response = await handleResponse(await buildHttpResponse(APIEndPoint.liveCategoryList, method: HttpMethod.GET));
  print('LiveCategoryList API response: ' + response.toString());
  if (response is List) {
    return AllLiveCategoryList.fromJson({"status": true, "message": "", "data": response});
  } else {
    return AllLiveCategoryList.fromJson(response);
  }
}

Future<LiveCategoryList> fetchCategoryChannels(int categoryId) async {
  final response = await handleResponse(
    await buildHttpResponse('${APIEndPoint.liveCategoryList}?category_id=$categoryId', method: HttpMethod.GET),
  );
  print('Category Channels API response: $response');
  if (response is List) {
    return LiveCategoryList.fromJson({"status": true, "message": "", "data": response});
  } else {
    return LiveCategoryList.fromJson(response);
  }
}

//endregion
