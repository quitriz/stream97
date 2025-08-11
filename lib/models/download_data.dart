import 'package:streamit_flutter/utils/constants.dart';

class DownloadData {
  int? id;
  String? description;
  String? duration;
  String? filePath;
  String? image;
  String? title;
  int? userId;
  bool? isDeleted;
  bool? inProgress;

  PostType? postType;

  DownloadData({
    this.id,
    this.description,
    this.duration,
    this.filePath,
    this.image,
    this.title,
    this.userId,
    this.isDeleted,
    this.inProgress,
    required this.postType,
  });

  factory DownloadData.fromJson(Map<String, dynamic> json) {
    return DownloadData(
      id: json['id'],
      description: json['description'],
      duration: json['duration'],
      filePath: json['file_path'],
      image: json['image'],
      title: json['title'],
      userId: json['userId'],
      isDeleted: json['isDeleted'],
      inProgress: json['inProgress'],
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
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['duration'] = this.duration;
    data['file_path'] = this.filePath;
    data['image'] = this.image;
    data['title'] = this.title;
    data['userId'] = this.userId;
    data['isDeleted'] = this.isDeleted;
    data['inProgress'] = this.inProgress;
    data['post_type']=this.postType;
    return data;
  }
}
