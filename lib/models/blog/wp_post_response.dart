import 'package:streamit_flutter/models/blog/content.dart';
import 'package:streamit_flutter/models/blog/wp_embedded_model.dart';

import '../../main.dart';

class WpPostResponse {
  List<dynamic>? acf;
  int? author;
  List<int>? categories;
  String? comment_status;
  Content? content;
  String? date;
  String? date_gmt;
  Content? excerpt;
  int? featured_media;
  String? format;
  Content? guid;
  int? id;
  String? link;
  Meta? meta;
  String? modified;
  String? modified_gmt;
  String? ping_status;
  String? slug;
  String? status;
  bool? sticky;
  List<int>? tags;
  String? template;
  Content? title;
  String? type;
  Embedded? embedded;
  bool? st_is_comment_open;
  bool? user_has_access;

  WpPostResponse({
    this.acf,
    this.author,
    this.categories,
    this.comment_status,
    this.content,
    this.date,
    this.date_gmt,
    this.excerpt,
    this.featured_media,
    this.format,
    this.guid,
    this.id,
    this.link,
    this.meta,
    this.modified,
    this.modified_gmt,
    this.ping_status,
    this.slug,
    this.status,
    this.sticky,
    this.tags,
    this.template,
    this.title,
    this.type,
    this.embedded,
    this.st_is_comment_open,
    this.user_has_access,
  });

  factory WpPostResponse.fromJson(Map<String, dynamic> json) {
    return WpPostResponse(
      acf: json['acf'] != null ? (json['acf'] as List).map((i) => i.fromJson(i)).toList() : null,
      author: json['author'],
      categories: json['categories'] != null ? new List<int>.from(json['categories']) : null,
      comment_status: json['comment_status'],
      content: json['content'] != null ? Content.fromJson(json['content']) : null,
      date: json['date'],
      date_gmt: json['date_gmt'],
      excerpt: json['excerpt'] != null ? Content.fromJson(json['excerpt']) : null,
      featured_media: json['featured_media'],
      format: json['format'],
      guid: json['guid'] != null ? Content.fromJson(json['guid']) : null,
      id: json['id'],
      link: json['link'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      modified: json['modified'],
      modified_gmt: json['modified_gmt'],
      ping_status: json['ping_status'],
      slug: json['slug'],
      status: json['status'],
      sticky: json['sticky'],
      tags: json['tags'] != null ? new List<int>.from(json['tags']) : null,
      template: json['template'],
      title: json['title'] != null ? Content.fromJson(json['title']) : null,
      type: json['type'],
      embedded: json['_embedded'] != null ? Embedded.fromJson(json['_embedded']) : null,
      st_is_comment_open: json['st_is_comment_open'],
      user_has_access: appStore.isInAppPurChaseEnable == false
          ? true
          : json['user_has_access'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['author'] = this.author;
    data['comment_status'] = this.comment_status;
    data['date'] = this.date;
    data['date_gmt'] = this.date_gmt;
    data['featured_media'] = this.featured_media;
    data['format'] = this.format;
    data['id'] = this.id;
    data['link'] = this.link;
    data['modified'] = this.modified;
    data['modified_gmt'] = this.modified_gmt;
    data['ping_status'] = this.ping_status;
    data['slug'] = this.slug;
    data['status'] = this.status;
    data['sticky'] = this.sticky;
    data['template'] = this.template;
    data['type'] = this.type;
    data['st_is_comment_open'] = this.st_is_comment_open;
    data['user_has_access'] = this.user_has_access;
    if (this.acf != null) {
      data['acf'] = this.acf!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories;
    }
    if (this.content != null) {
      data['content'] = this.content!.toJson();
    }
    if (this.excerpt != null) {
      data['excerpt'] = this.excerpt!.toJson();
    }
    if (this.guid != null) {
      data['guid'] = this.guid!.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    if (this.tags != null) {
      data['tags'] = this.tags;
    }
    if (this.title != null) {
      data['title'] = this.title!.toJson();
    }
    if (this.embedded != null) {
      data['_embedded'] = this.embedded!.toJson();
    }
    return data;
  }
}
class Meta {
  int? bbp_anonymous_reply_count;
  int? bbp_forum_subforum_count;
  int? bbp_reply_count;
  int? bbp_reply_count_hidden;
  int? bbp_topic_count;
  int? bbp_topic_count_hidden;
  int? bbp_total_reply_count;
  int? bbp_total_topic_count;
  int? bbp_voice_count;

  Meta(
      {this.bbp_anonymous_reply_count,
      this.bbp_forum_subforum_count,
      this.bbp_reply_count,
      this.bbp_reply_count_hidden,
      this.bbp_topic_count,
      this.bbp_topic_count_hidden,
      this.bbp_total_reply_count,
      this.bbp_total_topic_count,
      this.bbp_voice_count});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      bbp_anonymous_reply_count: json['_bbp_anonymous_reply_count'],
      bbp_forum_subforum_count: json['_bbp_forum_subforum_count'],
      bbp_reply_count: json['_bbp_reply_count'],
      bbp_reply_count_hidden: json['_bbp_reply_count_hidden'],
      bbp_topic_count: json['_bbp_topic_count'],
      bbp_topic_count_hidden: json['_bbp_topic_count_hidden'],
      bbp_total_reply_count: json['_bbp_total_reply_count'],
      bbp_total_topic_count: json['_bbp_total_topic_count'],
      bbp_voice_count: json['_bbp_voice_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_bbp_anonymous_reply_count'] = this.bbp_anonymous_reply_count;
    data['_bbp_forum_subforum_count'] = this.bbp_forum_subforum_count;
    data['_bbp_reply_count'] = this.bbp_reply_count;
    data['_bbp_reply_count_hidden'] = this.bbp_reply_count_hidden;
    data['_bbp_topic_count'] = this.bbp_topic_count;
    data['_bbp_topic_count_hidden'] = this.bbp_topic_count_hidden;
    data['_bbp_total_reply_count'] = this.bbp_total_reply_count;
    data['_bbp_total_topic_count'] = this.bbp_total_topic_count;
    data['_bbp_voice_count'] = this.bbp_voice_count;
    return data;
  }
}
