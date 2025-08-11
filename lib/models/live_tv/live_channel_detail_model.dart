class ChannelDetailsModel {
  bool? status;
  String? message;
  Data? data;

  ChannelDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory ChannelDetailsModel.fromJson(Map<String, dynamic> json) =>
      ChannelDetailsModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  LiveChannelDetails? details;
  List<RecommendedChannel>? recommendedChannels;

  Data({
    this.details,
    this.recommendedChannels,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        details: json["details"] == null
            ? null
            : LiveChannelDetails.fromJson(json["details"]),
        recommendedChannels: json["recommended_channels"] == null
            ? []
            : List<RecommendedChannel>.from(json["recommended_channels"]!
                .map((x) => RecommendedChannel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "details": details?.toJson(),
        "recommended_channels": recommendedChannels == null
            ? []
            : List<dynamic>.from(recommendedChannels!.map((x) => x.toJson())),
      };
}

class LiveChannelDetails {
  int? id;
  String? title;
  String? description;
  String? thumbnailImage;
  String? portraitImage;
  String? postType;
  String? videoUrl;
  String? shareUrl;
  String? liveStartedAt;
  String? liveStartedAtGmt;
  List<RecommendedChannel>? recommendedChannels;
  AdConfiguration? adConfiguration;

  LiveChannelDetails({
    this.id,
    this.title,
    this.description,
    this.thumbnailImage,
    this.portraitImage,
    this.postType,
    this.videoUrl,
    this.shareUrl,
    this.liveStartedAt,
    this.liveStartedAtGmt,
    this.recommendedChannels,
    this.adConfiguration,
  });

  factory LiveChannelDetails.fromJson(Map<String, dynamic> json) {
    return LiveChannelDetails(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailImage: json['thumbnail_image'],
      portraitImage: json['portrait_image'],
      postType: json['post_type'],
      videoUrl: json['video_url'],
      shareUrl: json['share_url'],
      liveStartedAt: json['live_started_at'],
      liveStartedAtGmt: json['live_started_at_gmt'],
      recommendedChannels: (json['recommended_channels'] as List?)
          ?.map((e) => RecommendedChannel.fromJson(e))
          .toList(),
      adConfiguration: json['ad_configuration'] != null
          ? AdConfiguration.fromJson(json['ad_configuration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'thumbnail_image': thumbnailImage,
        'portrait_image': portraitImage,
        'post_type': postType,
        'video_url': videoUrl,
        'share_url': shareUrl,
        'live_started_at': liveStartedAt,
        'live_started_at_gmt': liveStartedAtGmt,
        'recommended_channels':
            recommendedChannels?.map((e) => e.toJson()).toList(),
        'ad_configuration': adConfiguration?.toJson(),
      };
}

class AdConfiguration {
  bool? adsEnabled;
  String? adsType;
  String? vastUrl;
  bool? preRollDisplay;
  List<AdUnit>? preRollAdsList;
  bool? midRollDisplay;
  List<AdUnit>? midRollAdsList;
  int? midRollInterval;
  bool? postRollDisplay;
  List<AdUnit>? postRollAdsList;

  AdConfiguration({
    this.adsEnabled,
    this.adsType,
    this.vastUrl,
    this.preRollDisplay,
    this.preRollAdsList,
    this.midRollDisplay,
    this.midRollAdsList,
    this.midRollInterval,
    this.postRollDisplay,
    this.postRollAdsList,
  });

  factory AdConfiguration.fromJson(Map<String, dynamic> json) =>
      AdConfiguration(
        adsEnabled: json['ads_enabled'],
        adsType: json['ads_type'],
        vastUrl: json['vast_url'],
        preRollDisplay: json['pre_roll_display'],
        preRollAdsList: (json['pre_roll_ads_list'] as List?)
            ?.map((e) => AdUnit.fromJson(e))
            .toList(),
        midRollDisplay: json['mid_roll_display'],
        midRollAdsList: (json['mid_roll_ads_list'] as List?)
            ?.map((e) => AdUnit.fromJson(e))
            .toList(),
        midRollInterval: json['mid_roll_interval'],
        postRollDisplay: json['post_roll_display'],
        postRollAdsList: (json['post_roll_ads_list'] as List?)
            ?.map((e) => AdUnit.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'ads_enabled': adsEnabled,
        'ads_type': adsType,
        'vast_url': vastUrl,
        'pre_roll_display': preRollDisplay,
        'pre_roll_ads_list': preRollAdsList?.map((e) => e.toJson()).toList(),
        'mid_roll_display': midRollDisplay,
        'mid_roll_ads_list': midRollAdsList?.map((e) => e.toJson()).toList(),
        'mid_roll_interval': midRollInterval,
        'post_roll_display': postRollDisplay,
        'post_roll_ads_list': postRollAdsList?.map((e) => e.toJson()).toList(),
      };
}

class AdUnit {
  String? type;
  String? adFormat;
  String? content;
  String? videoUrl;
  int? duration;
  bool? fullScreen;
  bool? overlay;
  String? position;
  String? campaign;
  bool? skipEnabled;
  int? skipDuration;

  AdUnit({
    this.type,
    this.adFormat,
    this.content,
    this.videoUrl,
    this.duration,
    this.fullScreen,
    this.overlay,
    this.position,
    this.campaign,
    this.skipEnabled,
    this.skipDuration,
  });

  factory AdUnit.fromJson(Map<String, dynamic> json) => AdUnit(
        type: json['type'],
        adFormat: json['adFormat'],
        content: json['content'],
        videoUrl: json['videoUrl'],
        duration: json['duration'] is int
            ? json['duration']
            : int.tryParse(json['duration'].toString()),
        fullScreen: json['fullScreen'],
        overlay: json['overlay'],
        position: json['position'],
        campaign: json['campaign'],
        skipEnabled: json['skipenabled'],
        skipDuration: json['skipDuration'] is int
            ? json['skipDuration']
            : int.tryParse(json['skipDuration'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'adFormat': adFormat,
        'content': content,
        'videoUrl': videoUrl,
        'duration': duration,
        'fullScreen': fullScreen,
        'overlay': overlay,
        'position': position,
        'campaign': campaign,
        'skipenabled': skipEnabled,
        'skipDuration': skipDuration,
      };
}

class ChannelCategory {
  int? categoryId;
  String? categoryName;
  String? description;
  int? parentCategory;
  String? thumbnailImage;

  ChannelCategory({
    this.categoryId,
    this.categoryName,
    this.description,
    this.parentCategory,
    this.thumbnailImage,
  });

  factory ChannelCategory.fromJson(Map<String, dynamic> json) =>
      ChannelCategory(
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        description: json["description"],
        parentCategory: json["parent_category"],
        thumbnailImage: json["thumbnail_image"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_name": categoryName,
        "description": description,
        "parent_category": parentCategory,
        "thumbnail_image": thumbnailImage,
      };
}

class RecommendedChannel {
  int? id;
  String? title;
  String? thumbnailImage;
  String? portraitImage;
  String? postType;

  RecommendedChannel({
    this.id,
    this.title,
    this.thumbnailImage,
    this.portraitImage,
    this.postType,
  });

  factory RecommendedChannel.fromJson(Map<String, dynamic> json) =>
      RecommendedChannel(
        id: json['id'],
        title: json['title'],
        thumbnailImage: json['thumbnail_image'],
        portraitImage: json['portrait_image'],
        postType: json['post_type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail_image': thumbnailImage,
        'portrait_image': portraitImage,
        'post_type': postType,
      };
}
