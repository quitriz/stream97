class AllLiveCategoryList {
  bool? status;
  String? message;
  List<Data>? data;

  AllLiveCategoryList({
    this.status,
    this.message,
    this.data,
  });

  factory AllLiveCategoryList.fromJson(Map<String, dynamic> json) =>
      AllLiveCategoryList(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Data>.from(json["data"]!.map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Data {
  int? id;
  String? name;
  String? slug;
  String? description;
  int? parent;
  String? thumbnailImage;

  Data({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.parent,
    this.thumbnailImage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        parent: json["parent"],
        thumbnailImage: json["thumbnail_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "parent": parent,
        "thumbnail_image": thumbnailImage,
      };
}

/// Category Detail List
class LiveCategoryList {
  bool? status;
  String? message;
  List<CategoryData>? data;

  LiveCategoryList({
    this.status,
    this.message,
    this.data,
  });

  factory LiveCategoryList.fromJson(Map<String, dynamic> json) =>
      LiveCategoryList(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CategoryData>.from(
                json["data"]!.map((x) => CategoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CategoryData {
  int? id;
  String? title;
  String? thumbnailImage;
  String? portraitImage;
  String? postType;

  CategoryData({
    this.id,
    this.title,
    this.thumbnailImage,
    this.portraitImage,
    this.postType,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
        id: json["id"],
        title: json["title"],
        thumbnailImage: json["thumbnail_image"],
        portraitImage: json["portrait_image"],
        postType: json["post_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumbnail_image": thumbnailImage,
        "portrait_image": portraitImage,
        "post_type": postType,
      };
}
