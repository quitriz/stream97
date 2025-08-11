import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/models/resume_video_model.dart';
import 'package:streamit_flutter/utils/constants.dart';

class CommonDataListModel {
  int? id;
  String? title;
  String? image;
  PostType postType;
  String? characterName;
  String? releaseYear;
  String? shareUrl;
  String? runTime;
  ContinueWatchModel? watchedDuration;
  String? trailerLink;
  String? attachment;
  String? releaseDate;
  String? category;
  String? description;
  String? trailerLinkType;
  String? channelStreamType;
  String? portraitImage;
  bool? isUpcoming;
  AdConfiguration? adConfiguration;

  CommonDataListModel({
    this.id,
    this.title,
    this.image,
    required this.postType,
    this.characterName,
    this.releaseYear,
    this.shareUrl,
    this.runTime,
    this.watchedDuration,
    this.trailerLink,
    this.attachment,
    this.releaseDate,
    this.category,
    this.description,
    this.trailerLinkType,
    this.channelStreamType,
    this.portraitImage,
    this.isUpcoming,
    this.adConfiguration,
  });

  factory CommonDataListModel.fromJson(Map<String, dynamic> json) {
    return CommonDataListModel(
      id: json['id'],
      title: json['title'],
      image: json['thumbnail_image'],
      postType: (json['post_type'] != null)
          ? {
                'movie': PostType.MOVIE,
                'episode': PostType.EPISODE,
                'tv_show': PostType.TV_SHOW,
                'video': PostType.VIDEO,
                'live_tv': PostType.CHANNEL,
              }[json['post_type']] ??
              PostType.NONE
          : PostType.NONE,
      characterName: json['character_name'],
      releaseYear: json['release_year'],
      shareUrl: json['share_url'],
      runTime: json['run_time'],
      watchedDuration: json['watched_duration'] != null
          ? ContinueWatchModel.fromJson(json['watched_duration'])
          : null,
      trailerLink: json['trailer_link'],
      attachment: json['attachment'],
      releaseDate: json['release_date'],
      trailerLinkType: json["trailer_link_type"],
      channelStreamType: json['stream_type'],
      portraitImage: json['portrait_image'],
      isUpcoming: json['is_upcoming'] ?? true,
      adConfiguration: json['ad_configuration'] != null
          ? AdConfiguration.fromJson(json['ad_configuration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['thumbnail_image'] = this.image;
    data['postType'] = this.postType.toString();
    data['character_name'] = this.characterName;
    data['release_year'] = this.releaseYear;
    data['share_url'] = this.shareUrl;
    data['run_time'] = this.runTime;
    if (this.watchedDuration != null) {
      data['watched_duration'] = this.watchedDuration!.toJson();
    }
    data['trailer_link'] = this.trailerLink;
    data["trailer_link_type"] = this.trailerLinkType;
    data['attachment'] = this.attachment;
    data['release_date'] = this.releaseDate;
    data['stream_type'] = this.channelStreamType;
    data['portrait_image'] = this.portraitImage;
    data['is_upcoming'] = this.isUpcoming;
    if (this.adConfiguration != null) {
      data['ad_configuration'] = this.adConfiguration!.toJson();
    }
    return data;
  }
}

class RecentSearchListModel {
  int? id;
  String? term;
  String? timeStamp;

  RecentSearchListModel(
      {required this.id, required this.term, required this.timeStamp});
  factory RecentSearchListModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchListModel(
      id: json['id'],
      term: json['term'],
      timeStamp: json['timestamp'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['term'] = this.term;
    data['timestamp'] = this.timeStamp;
    return data;
  }
}
