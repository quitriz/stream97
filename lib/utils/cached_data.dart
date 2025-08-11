import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/dashboard_response.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/utils/constants.dart';

//region  Cached Data keys
class ResponseKey {
  static const homeResponse = "home_response";
  static const movieResponse = "movie_response";
  static const tvShowResponse = "tv_show_response";
  static const videoResponse = "video_response";
  static const movieGenreResponse = "movie_genre_response";
  static const tvShowGenreResponse = "tv_show_genre_response";
  static const videoGenreResponse = "video_genre_response";
}
//endregion

//region Base Cached set and get
class CachedData {
  static void storeResponse({Map<String, dynamic>? networkResponse, List<Map>? listNetworkData, required String responseKey}) async {
    await setValue(responseKey, jsonEncode(networkResponse != null ? networkResponse : listNetworkData));
  }

  static dynamic getCachedData({required String cachedKey}) {
    return getStringAsync(cachedKey).isNotEmpty ? jsonDecode(getStringAsync(cachedKey)) : null;
  }
}
//endregion

//region Dashboard Cached Data
class DashboardCachedData {
  static String _dashboardCachedDataStoreKey = ResponseKey.homeResponse;

  static void storeData({required String dashboardTypeKey, required Map<String, dynamic> data}) {
    if (dashboardTypeKey == dashboardTypeHome) {
      _dashboardCachedDataStoreKey = ResponseKey.homeResponse;
    } else if (dashboardTypeKey == dashboardTypeMovie) {
      _dashboardCachedDataStoreKey = ResponseKey.movieResponse;
    } else if (dashboardTypeKey == dashboardTypeTVShow) {
      _dashboardCachedDataStoreKey = ResponseKey.tvShowResponse;
    } else {
      _dashboardCachedDataStoreKey = ResponseKey.videoResponse;
    }
    CachedData.storeResponse(networkResponse: data, responseKey: _dashboardCachedDataStoreKey);
  }

  static DashboardResponse? getData({required String dashboardTypeKey}) {
    if (dashboardTypeKey == dashboardTypeHome) {
      return CachedData.getCachedData(cachedKey: ResponseKey.homeResponse) != null ? DashboardResponse.fromJson(CachedData.getCachedData(cachedKey: ResponseKey.homeResponse)) : null;
    } else if (dashboardTypeKey == dashboardTypeMovie) {
      return CachedData.getCachedData(cachedKey: ResponseKey.movieResponse) != null ? DashboardResponse.fromJson(CachedData.getCachedData(cachedKey: ResponseKey.movieResponse)) : null;
    } else if (dashboardTypeKey == dashboardTypeTVShow) {
      return CachedData.getCachedData(cachedKey: ResponseKey.tvShowResponse) != null ? DashboardResponse.fromJson(CachedData.getCachedData(cachedKey: ResponseKey.tvShowResponse)) : null;
    } else {
      return CachedData.getCachedData(cachedKey: ResponseKey.videoResponse) != null ? DashboardResponse.fromJson(CachedData.getCachedData(cachedKey: ResponseKey.videoResponse)) : null;
    }
  }
}
//endregion

//region Genre Cached Data
class GenreCachedData {
  static String _genreCachedDataStoreKey = ResponseKey.movieGenreResponse;

  static void storeData({required String genreTypeKey, required List<Map> data}) {
    if (genreTypeKey == dashboardTypeMovie) {
      _genreCachedDataStoreKey = ResponseKey.movieGenreResponse;
    } else if (genreTypeKey == dashboardTypeTVShow) {
      _genreCachedDataStoreKey = ResponseKey.tvShowGenreResponse;
    } else {
      _genreCachedDataStoreKey = ResponseKey.videoGenreResponse;
    }
    CachedData.storeResponse(listNetworkData: data, responseKey: _genreCachedDataStoreKey);
  }

  static List<GenreData> getData({required String dashboardTypeKey}) {
    if (dashboardTypeKey == dashboardTypeMovie) {
      return CachedData.getCachedData(cachedKey: ResponseKey.movieGenreResponse) != null
          ? (CachedData.getCachedData(cachedKey: ResponseKey.movieGenreResponse) as List).map((e) => GenreData.fromJson(e)).toList()
          : [];
    } else if (dashboardTypeKey == dashboardTypeTVShow) {
      return CachedData.getCachedData(cachedKey: ResponseKey.tvShowGenreResponse) != null
          ? (CachedData.getCachedData(cachedKey: ResponseKey.tvShowGenreResponse) as List).map((e) => GenreData.fromJson(e)).toList()
          : [];
    } else {
      return CachedData.getCachedData(cachedKey: ResponseKey.videoGenreResponse) != null
          ? (CachedData.getCachedData(cachedKey: ResponseKey.videoGenreResponse) as List).map((e) => GenreData.fromJson(e)).toList()
          : [];
    }
  }
}
//endregion
