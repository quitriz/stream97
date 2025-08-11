import 'package:streamit_flutter/models/movie_episode/movie_data.dart';

class Season {
  String? description;
  List<MovieData>? episodes;
  String? image;
  String? name;
  int? position;
  String? year;

  Season({this.description, this.episodes, this.image, this.name, this.position, this.year});

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      description: json['description'],
      episodes: json['episodes'] != null ? (json['episodes'] as List).map((i) => MovieData.fromJson(i)).toList() : null,
      image: json['image'],
      name: json['name'],
      position: json['position'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['image'] = this.image;
    data['name'] = this.name;
    data['position'] = this.position;
    data['year'] = this.year;
    if (this.episodes != null) {
      data['episodes'] = this.episodes!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
