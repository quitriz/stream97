import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';

import 'movie_data.dart';

class MovieDetailResponse {
  MovieData? data;
  List<CommonDataListModel>? recommendedMovie;
  List<CommonDataListModel>? upcomingMovie;
  List<CommonDataListModel>? upcomingVideo;

  MovieDetailResponse({
    this.data,
    this.recommendedMovie,
    this.upcomingMovie,
    this.upcomingVideo,
  });

  factory MovieDetailResponse.fromJson(Map<String, dynamic> json) {
    return MovieDetailResponse(
      data: json['details'] != null ? MovieData.fromJson(json['details']) : null,
      recommendedMovie: json['recommended_movies'] != null ? (json['recommended_movies'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
      upcomingMovie: json['upcoming_movies'] != null ? (json['upcoming_movies'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
      upcomingVideo: json['upcoming_videos'] != null ? (json['upcoming_videos'] as List).map((e) => CommonDataListModel.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['details'] = this.data!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.recommendedMovie != null) {
      data['recommended_movies'] = this.recommendedMovie!.map((v) => v.toJson()).toList();
    }
    if (this.upcomingMovie != null) {
      data['upcoming_movies'] = this.upcomingMovie!.map((v) => v.toJson()).toList();
    }
    if (this.upcomingVideo != null) {
      data['upcoming_videos'] = this.upcomingVideo!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
