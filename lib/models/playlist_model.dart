// class PlaylistModel {
//   String commentCount;
//   String commentStatus;
//   String filter;
//   String guid;
//   int iD;
//   int menuOrder;
//   String pingStatus;
//   String pinged;
//   String postAuthor;
//   String postContent;
//   String postContentFiltered;
//   String postDate;
//   String postDateGmt;
//   String postExcerpt;
//   String postMimeType;
//   String postModified;
//   String postModifiedGmt;
//   String postName;
//   int postParent;
//   String postPassword;
//   String postStatus;
//   String postTitle;
//   String postType;
//   String toPing;
//   bool isInPlaylist;

//   PlaylistModel({
//     this.commentCount = "",
//     this.commentStatus = "",
//     this.filter = "",
//     this.guid = "",
//     this.iD = -1,
//     this.menuOrder = -1,
//     this.pingStatus = "",
//     this.pinged = "",
//     this.postAuthor = "",
//     this.postContent = "",
//     this.postContentFiltered = "",
//     this.postDate = "",
//     this.postDateGmt = "",
//     this.postExcerpt = "",
//     this.postMimeType = "",
//     this.postModified = "",
//     this.postModifiedGmt = "",
//     this.postName = "",
//     this.postParent = -1,
//     this.postPassword = "",
//     this.postStatus = "",
//     this.postTitle = "",
//     this.postType = "",
//     this.toPing = "",
//     this.isInPlaylist = false,
//   });

//   factory PlaylistModel.fromJson(Map<String, dynamic> json) {
//     return PlaylistModel(
//       commentCount: json['comment_count'],
//       commentStatus: json['comment_status'],
//       filter: json['filter'],
//       guid: json['guid'],
//       iD: json['ID'],
//       menuOrder: json['menu_order'],
//       pingStatus: json['ping_status'],
//       pinged: json['pinged'],
//       postAuthor: json['post_author'],
//       postContent: json['post_content'],
//       postContentFiltered: json['post_content_filtered'],
//       postDate: json['post_date'],
//       postDateGmt: json['post_date_gmt'],
//       postExcerpt: json['post_excerpt'],
//       postMimeType: json['post_mime_type'],
//       postModified: json['post_modified'],
//       postModifiedGmt: json['post_modified_gmt'],
//       postName: json['post_name'],
//       postParent: json['post_parent'],
//       postPassword: json['post_password'],
//       postStatus: json['post_status'],
//       postTitle: json['post_title'],
//       postType: json['post_type'],
//       toPing: json['to_ping'],
//       isInPlaylist: json['is_in_playlist'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['comment_count'] = this.commentCount;
//     data['comment_status'] = this.commentStatus;
//     data['filter'] = this.filter;
//     data['guid'] = this.guid;
//     data['iD'] = this.iD;
//     data['menu_order'] = this.menuOrder;
//     data['ping_status'] = this.pingStatus;
//     data['pinged'] = this.pinged;
//     data['post_author'] = this.postAuthor;
//     data['post_content'] = this.postContent;
//     data['post_content_filtered'] = this.postContentFiltered;
//     data['post_date'] = this.postDate;
//     data['post_date_gmt'] = this.postDateGmt;
//     data['post_excerpt'] = this.postExcerpt;
//     data['post_mime_type'] = this.postMimeType;
//     data['post_modified'] = this.postModified;
//     data['post_modified_gmt'] = this.postModifiedGmt;
//     data['post_name'] = this.postName;
//     data['post_parent'] = this.postParent;
//     data['post_password'] = this.postPassword;
//     data['post_status'] = this.postStatus;
//     data['post_title'] = this.postTitle;
//     data['post_type'] = this.postType;
//     data['to_ping'] = this.toPing;
//     data['is_in_playlist'] = this.isInPlaylist;

//     return data;
//   }
// }

class PlaylistResp {
  bool status;
  String message;
  List<PlaylistModel> data;

  PlaylistResp({
    this.status = false,
    this.message = "",
    this.data = const <PlaylistModel>[],
  });

  factory PlaylistResp.fromJson(Map<String, dynamic> json) {
    return PlaylistResp(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      data: json['data'] is List
          ? List<PlaylistModel>.from(json['data'].map((x) => PlaylistModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class PlaylistModel {
  int playlistId;
  String playlistName;
  String playlistSlug;
  String image;
  String dataCount;
  String postType;
  bool isInPlaylist;
  String label;

  PlaylistModel({
    this.playlistId = -1,
    this.playlistName = "",
    this.playlistSlug = "",
    this.image = "",
    this.dataCount = "",
    this.postType = "",
    this.isInPlaylist = false,
    this.label = "",
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      playlistId: json['playlist_id'] is int ? json['playlist_id'] : -1,
      playlistName:
          json['playlist_name'] is String ? json['playlist_name'] : "",
      playlistSlug:
          json['playlist_slug'] is String ? json['playlist_slug'] : "",
      image: json['image'] is String ? json['image'] : "",
      dataCount: json['data_count'] is String ? json['data_count'] : "",
      postType: json['post_type'] is String ? json['post_type'] : "",
      isInPlaylist: json['is_in_playlist'] is bool ? json['is_in_playlist'] : false,
      label: json['label'] is String ? json['label'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playlistId,
      'playlist_name': playlistName,
      'playlist_slug': playlistSlug,
      'image': image,
      'data_count': dataCount,
      'post_type': postType,
      'is_in_playlist': isInPlaylist,
      'label': label,
    };
  }
}
