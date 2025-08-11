import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/models/movie_episode/sources.dart';
import 'package:streamit_flutter/utils/constants.dart';

class MovieData {
  String? description;
  String? excerpt;
  List<String>? genre;
  int? id;
  String? image;
  List<String>? tag;
  String? title;
  String? logo;
  String? avgRating;
  String? censorRating;
  String? embedContent;
  String? choice;
  String? publishDate;
  String? publishDateGmt;
  String? releaseDate;
  String? runTime;
  String? trailerLink;
  String? urlLink;
  String? file;
  bool? isInWatchList;
  bool? isLiked;
  int? likes;
  String? attachment;
  List<RestrictSubscriptionPlan>? subscriptionLevels;
  String? noOfComments;
  dynamic imdbRating;
  MovieSeason? seasons;
  int? views;
  PostType? postType;
  List<CommonModelMovieDetail>? castsList;
  List<CommonModelMovieDetail>? crews;
  String? shareUrl;
  bool? userHasAccess;
  List<Sources>? sourcesList;
  bool? isCommentOpen;
  List<MovieComment>? comments;
  String? episodeFile;
  bool? isPasswordProtected;
  bool? isUpcoming;
  String trailerLinkType;
  AdConfiguration? adConfiguration;

  MovieData({
    this.avgRating,
    this.censorRating,
    this.description,
    this.embedContent,
    this.excerpt,
    this.genre,
    this.id,
    this.image,
    this.logo,
    this.tag,
    this.title,
    this.choice,
    this.publishDate,
    this.publishDateGmt,
    this.releaseDate,
    this.runTime,
    this.trailerLink,
    this.urlLink,
    this.isInWatchList,
    this.isLiked,
    this.likes,
    this.postType,
    this.file,
    this.attachment,
    this.subscriptionLevels,
    this.views,
    this.imdbRating,
    this.noOfComments,
    this.castsList,
    this.shareUrl,
    this.sourcesList,
    this.isCommentOpen,
    this.crews,
    this.userHasAccess,
    this.seasons,
    this.comments,
    this.episodeFile,
    this.isPasswordProtected,
    this.isUpcoming,
    this.trailerLinkType = '',
    this.adConfiguration,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) {
    return MovieData(
      avgRating: json['avg_rating'],
      censorRating: json['censor_rating'],
      description: json['description'],
      excerpt: json['excerpt'],
      embedContent: json['embed_content'],
      genre: json['genre'] != null ? List<String>.from(json['genre']) : null,
      id: json['id'].toString().toInt(),
      image: json['image'],
      tag: json['tag'] != null ? List<String>.from(json['tag']) : null,
      title: json['title'],
      logo: json['logo'],
      likes: json['likes'],
      choice: json['post_type'] != null
          ? json['post_type'] == 'movie'
              ? json['movie_choice']
              : json['post_type'] == 'episode'
                  ? json['episode_choice']
                  : json['video_choice']
          : null,
      publishDate: json['publish_date'],
      publishDateGmt: json['publish_date_gmt'],
      releaseDate: json['release_date'],
      runTime: json['run_time'],
      trailerLink: json['trailer_link'],
      urlLink: json['url_link'],
      isInWatchList: json['is_watchlist'],
      file: json['post_type'] != null
          ? json['post_type'] == 'movie'
              ? json['movie_file']
              : json['video_file']
          : null,
      isLiked: json['is_liked'],
      postType: json['post_type'] != null
          ? json['post_type'] == 'movie'
              ? PostType.MOVIE
              : json['post_type'] == 'episode'
                  ? PostType.EPISODE
                  : json['post_type'] == 'tv_show'
                      ? PostType.TV_SHOW
                      : json['post_type'] == 'video'
                          ? PostType.VIDEO
                          : PostType.NONE
          : PostType.NONE,
      attachment: json['attachment'],
      subscriptionLevels: json['subscription_levels'] != null
          ? (json['subscription_levels'] as List)
              .map((e) => RestrictSubscriptionPlan.fromJson(e))
              .toList()
          : null,
      views: json['views'],
      imdbRating: json['imdb_rating'] != null ? json['imdb_rating'] : null,
      noOfComments: json['no_of_comments'],
      castsList: json['casts'] != null
          ? (json['casts'] as List)
              .map((e) => CommonModelMovieDetail.fromJson(e))
              .toList()
          : null,
      crews: json['crews'] != null
          ? (json['crews'] as List)
              .map((e) => CommonModelMovieDetail.fromJson(e))
              .toList()
          : null,
      shareUrl: json['share_url'],
      sourcesList: json['sources'] == null
          ? []
          : (json['sources'] as List).map((e) => Sources.fromJson(e)).toList(),
      isCommentOpen: json['is_comment_open'],
      userHasAccess: json['user_has_access'],
      seasons: json['seasons'] != null
          ? MovieSeason.fromJson(json['seasons'])
          : null,
      episodeFile: json['episode_file'],
      isPasswordProtected: json['is_password_protected'] is bool
          ? json['is_password_protected']
          : false,
      trailerLinkType:
          json['trailer_link_type'] is String ? json['trailer_link_type'] : '',
      isUpcoming: json['is_upcoming'] ?? true,
      adConfiguration: json['ad_configuration'] != null
          ? AdConfiguration.fromJson(json['ad_configuration'])
          : null, // Added adConfiguration parsing
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['movie_file'] = file;
    data['description'] = description;
    data['excerpt'] = excerpt;
    data['id'] = id;
    data['image'] = image;
    data['title'] = title;
    data['avg_rating'] = avgRating;
    data['censor_rating'] = censorRating;
    data['embed_content'] = embedContent;
    data['movie_choice'] = choice;
    data['publish_date'] = publishDate;
    data['publish_date_gmt'] = publishDateGmt;
    data['release_date'] = releaseDate;
    data['run_time'] = runTime;
    data['trailer_link'] = trailerLink;
    data['url_link'] = urlLink;
    data['logo'] = logo;
    data['is_watchlist'] = isInWatchList;
    data['is_liked'] = isLiked;
    data['likes'] = likes;
    data['episode_file'] = episodeFile;
    data['postType'] = postType.toString();
    if (genre != null) {
      data['genre'] = genre;
    }
    if (tag != null) {
      data['tag'] = tag;
    }
    data['attachment'] = attachment;
    if (subscriptionLevels != null) {
      data['subscription_levels'] =
          subscriptionLevels!.map((e) => e.toJson()).toList();
    }
    data['views'] = views;
    data['imdb_rating'] = imdbRating;
    data['no_of_comments'] = noOfComments;
    if (castsList != null) {
      data['casts'] = castsList;
    }
    if (crews != null) {
      data['crews'] = crews;
    }
    data['share_url'] = shareUrl;
    if (sourcesList != null) {
      data['sources'] = sourcesList!.map((e) => e.toJson()).toList();
    }
    data['is_comment_open'] = isCommentOpen;
    data['user_has_access'] = userHasAccess;
    if (seasons != null) {
      data['seasons'] = seasons!.toJson();
    }
    if (comments != null) {
      data['comments'] = comments!.map((e) => e.toJson()).toList();
    }
    data['is_password_protected'] = isPasswordProtected;
    data['trailer_link_type'] = trailerLinkType;
    data['is_upcoming'] = isUpcoming;
    if (adConfiguration != null) {
      data['ad_configuration'] =
          adConfiguration!.toJson(); // Added adConfiguration serialization
    }
    return data;
  }
}

class MovieComment {
  String? commentID;
  String? commentPostID;
  String? commentAuthor;
  String? commentAuthorEmail;
  String? commentAuthorUrl;
  String? commentAuthorIP;
  String? commentDate;
  String? commentDateGmt;
  String? commentContent;
  String? commentKarma;
  String? commentApproved;
  String? commentAgent;
  String? commentType;
  String? commentParent;
  String? userId;
  int? rating;

  MovieComment({
    this.commentID,
    this.commentPostID,
    this.commentAuthor,
    this.commentAuthorEmail,
    this.commentAuthorUrl,
    this.commentAuthorIP,
    this.commentDate,
    this.commentDateGmt,
    this.commentContent,
    this.commentKarma,
    this.commentApproved,
    this.commentAgent,
    this.commentType,
    this.commentParent,
    this.userId,
    this.rating,
  });

  MovieComment.fromJson(dynamic json) {
    commentID = json['comment_ID'];
    commentPostID = json['comment_post_ID'];
    commentAuthor = json['comment_author'];
    commentAuthorEmail = json['comment_author_email'];
    commentAuthorUrl = json['comment_author_url'];
    commentAuthorIP = json['comment_author_IP'];
    commentDate = json['comment_date'];
    commentDateGmt = json['comment_date_gmt'];
    commentContent = json['comment_content'];
    commentKarma = json['comment_karma'];
    commentApproved = json['comment_approved'];
    commentAgent = json['comment_agent'];
    commentType = json['comment_type'];
    commentParent = json['comment_parent'];
    userId = json['user_id'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['comment_ID'] = commentID;
    map['comment_post_ID'] = commentPostID;
    map['comment_author'] = commentAuthor;
    map['comment_author_email'] = commentAuthorEmail;
    map['comment_author_url'] = commentAuthorUrl;
    map['comment_author_IP'] = commentAuthorIP;
    map['comment_date'] = commentDate;
    map['comment_date_gmt'] = commentDateGmt;
    map['comment_content'] = commentContent;
    map['comment_karma'] = commentKarma;
    map['comment_approved'] = commentApproved;
    map['comment_agent'] = commentAgent;
    map['comment_type'] = commentType;
    map['comment_parent'] = commentParent;
    map['user_id'] = userId;
    map['rating'] = rating;
    return map;
  }
}

class Review {
  bool status;
  String messate;
  List<ReviewModel> reviewList;

  Review({
    required this.status,
    required this.messate,
    required this.reviewList,
  });

  Review.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        messate = json['message'],
        reviewList =
            (json['data'] as List).map((i) => ReviewModel.fromJson(i)).toList();
}

class ReviewModel {
  String userImage;
  String userName;
  String rateContent;
  int rate;
  String date;
  int rateId;
  int userId;

  ReviewModel({
    required this.userImage,
    required this.userName,
    required this.rateContent,
    required this.rate,
    required this.date,
    required this.rateId,
    required this.userId,
  });

  ReviewModel.fromJson(Map<String, dynamic> json)
      : userImage = json['user_image'],
        userName = json['user_name'],
        rateContent = json['rate_content'],
        rate = int.tryParse(json['rate'].toString()) ?? 0,
        date = json['date'],
        rateId = int.tryParse(json['rate_id'].toString()) ?? 0,
        userId = int.tryParse(json['user_id'].toString()) ?? 0;
}