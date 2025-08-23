import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/utils/constants.dart';

class DashboardResponse {
  List<CommonDataListModel>? banner;
  List<Slider>? sliders;
  List<CommonDataListModel>? continueWatch;

  DashboardResponse({
    this.banner,
    this.sliders,
    this.continueWatch,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      banner: json['banner'] != null ? (json['banner'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
      sliders: json['sliders'] != null ? (json['sliders'] as List).map((i) => Slider.fromJson(i)).toList() : null,
      continueWatch: json['continue_watch'] != null ? (json['continue_watch'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banner != null) {
      data['banner'] = this.banner!.map((v) => v.toJson()).toList();
    }
    if (this.continueWatch != null) {
      data['continue_watch'] = this.continueWatch!.map((v) => v.toJson()).toList();
    }
    if (this.sliders != null) {
      data['sliders'] = this.sliders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slider {
  List<CommonDataListModel>? data;
  String? title;
  bool? viewAll;
  String? type;
  List? ids;
  PostType? postType;
  bool? isRent;
  String? purchaseType;

  Slider({this.data, this.title, this.viewAll, this.type, this.ids, this.postType, this.isRent, this.purchaseType});

  factory Slider.fromJson(Map<String, dynamic> json) {
    return Slider(
      data: json['data'] != null ? (json['data'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
      title: json['title'],
      viewAll: json['view_all'],
      type: json['type'],
      ids: json['ids'] == null ? [] : json['ids'],
      isRent: json['is_rent'] ?? false,
      purchaseType: json['purchase_type'] ?? '',
      postType: json['post_type'] != null
          ? json['post_type'] == 'movie'
              ? PostType.MOVIE
              : json['post_type'] == 'episode'
                  ? PostType.EPISODE
                  : json['post_type'] == 'tv_show'
                      ? PostType.TV_SHOW
                      : json['post_type'] == 'video'
                          ? PostType.VIDEO
                          : json['post_type'] == 'channel'
                              ? PostType.CHANNEL
                              : PostType.NONE
          : PostType.NONE,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['view_all'] = this.viewAll;
    data['type'] = this.type;
    return data;
  }
}
