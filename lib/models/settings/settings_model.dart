class SettingsModel {
  SettingsModel({
    this.comment,
    this.pmproCurrency,
    this.currencySymbol,
    this.showTitles,
    this.showAds,
    this.pmproPayments,
    this.isMembershipEnabled,
    this.wooConsumerKey = "",
    this.wooConsumerSecret = "",
    this.isLiveEnabled = false,
  });

  factory SettingsModel.fromJson(dynamic json) {
    return SettingsModel(
      showAds: json['show_ads'] is int ? json['show_ads'] : 0,
      showTitles: json['show_titles'] is int ? json['show_titles'] : 0,
      comment: json['comment'] is Map ? Comment.fromJson(json['comment']) : Comment(),
      pmproCurrency: json['pmpro_currency'] is String ? json['pmpro_currency'] : "",
      pmproPayments: json['pmpro_payments'] is Map<String, dynamic> ? PmproPayments.fromJson(json['pmpro_payments']) : null,
      currencySymbol: json['currency_symbol'] is String ? json['currency_symbol'] : "",
      isMembershipEnabled: json['is_membership_enable'] is int ? json['is_membership_enable'] : 0,
      wooConsumerKey: json['wc_consumer_key'] is String ? json['wc_consumer_key'] : "",
      wooConsumerSecret: json['wc_consumer_secret'] is String ? json['wc_consumer_secret'] : "",
      isLiveEnabled: json['is_live_streaming_enable'] is bool ? json['is_live_streaming_enable'] : false,
    );
  }

  Comment? comment;
  String? pmproCurrency;
  String? currencySymbol;
  int? showTitles;
  int? showAds;

  int? isMembershipEnabled;
  PmproPayments? pmproPayments;

  bool get isPaymentMethodAvailable => pmproPayments != null;
  String? wooConsumerKey;
  String? wooConsumerSecret;
  bool? isLiveEnabled;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (comment != null) {
      map['comment'] = comment!.toJson();
    }
    map['pmpro_currency'] = pmproCurrency;
    map['currency_symbol'] = currencySymbol;
    map['show_titles'] = showTitles;
    map['show_ads'] = showAds;
    map['is_membership_enable'] = isMembershipEnabled;
    map['pmpro_payments'] = pmproPayments?.toJson();
    map['is_live_streaming_enable'] = isLiveEnabled;

    return map;
  }
}

class Comment {
  Comment({
    this.movieComments,
    this.tvShowComments,
    this.episodeComments,
    this.videoComments,
  });

  Comment.fromJson(dynamic json) {
    movieComments = json['movie_comments'];
    tvShowComments = json['tv_show_comments'];
    episodeComments = json['episode_comments'];
    videoComments = json['video_comments'];
  }

  int? movieComments;
  int? tvShowComments;
  int? episodeComments;
  int? videoComments;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['movie_comments'] = movieComments;
    map['tv_show_comments'] = tvShowComments;
    map['episode_comments'] = episodeComments;
    map['video_comments'] = videoComments;
    return map;
  }
}

class PmproPayments {
  String type;
  String entitlementId;
  String googleApiKey;
  String appleApiKey;

  PmproPayments({
    this.type = "",
    this.entitlementId = "",
    this.googleApiKey = "",
    this.appleApiKey = "",
  });

  factory PmproPayments.fromJson(Map<String, dynamic> json) {
    return PmproPayments(
      type: json['type'] is String ? json['type'] : "",
      entitlementId: json['entitlement_id'] is String ? json['entitlement_id'] : "",
      googleApiKey: json['google_api_key'] is String ? json['google_api_key'] : "",
      appleApiKey: json['apple_api_key'] is String ? json['apple_api_key'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'entitlement_id': entitlementId,
      'google_api_key': googleApiKey,
      'apple_api_key': appleApiKey,
    };
  }
}