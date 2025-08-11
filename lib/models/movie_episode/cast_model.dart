import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';

class CastModel {
  Data? data;
  List<CommonDataListModel>? mostViewedContent;

  CastModel({this.data, this.mostViewedContent});

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      data: json['details'] != null ? Data.fromJson(json['details']) : null,
      mostViewedContent: json['most_viewed_content'] != null
          ? (json['most_viewed_content'] as List).map((i) {
              return CommonDataListModel.fromJson(i);
            }).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['details'] = this.data!.toJson();
    }
    if (this.mostViewedContent != null) {
      data['most_viewed_content'] = this.mostViewedContent!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Data {
  String? alsoKnownAs;
  String? birthday;
  String? category;
  int? credits;
  String? deathDay;
  String? id;
  String? image;
  String? placeOfBirth;
  String? title;
  String? description;

  Data({
    this.alsoKnownAs,
    this.birthday,
    this.category,
    this.credits,
    this.deathDay,
    this.id,
    this.image,
    this.placeOfBirth,
    this.title,
    this.description,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      alsoKnownAs: json['also_known_as'],
      birthday: json['birthday'],
      category: json['category'],
      credits: json['credits'],
      deathDay: json['deathday'],
      id: json['id'],
      image: json['image'],
      placeOfBirth: json['place_of_birth'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['also_known_as'] = this.alsoKnownAs;
    data['birthday'] = this.birthday;
    data['category'] = this.category;
    data['credits'] = this.credits;
    data['id'] = this.id;
    data['image'] = this.image;
    data['place_of_birth'] = this.placeOfBirth;
    data['title'] = this.title;
    if (this.deathDay != null) {
      data['deathday'] = this.deathDay;
    }
    data['description'] = this.description;
    return data;
  }
}
