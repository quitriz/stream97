class RestrictSubscriptionPlan {
  String? planId;
  String? label;

  RestrictSubscriptionPlan({this.planId, this.label});

  factory RestrictSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return RestrictSubscriptionPlan(planId: json['id'].toString(), label: json['label']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.planId;
    data['label'] = this.label;
    return data;
  }
}

class MovieSeason {
  int? count;
  List<CommonModelMovieDetail>? data;

  MovieSeason({this.count, this.data});

  factory MovieSeason.fromJson(Map<String, dynamic> json) {
    return MovieSeason(
      count: json['count'],
      data: json['data'] != null ? (json['data'] as List).map((i) => CommonModelMovieDetail.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommonModelMovieDetail {
  String? id;
  String? name;
  String? slug;
  String? image;

  CommonModelMovieDetail({this.id, this.name, this.slug, this.image});

  factory CommonModelMovieDetail.fromJson(Map<String, dynamic> json) {
    return CommonModelMovieDetail(
      id: json['id'].toString(),
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['image'] = this.image;

    return data;
  }
}
