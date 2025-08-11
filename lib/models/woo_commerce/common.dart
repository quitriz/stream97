class Attribute {
  int? id;
  String? name;
  List<String>? options;
  String? optionString;
  int? position;
  bool? variation;
  bool? visible;
  String? dropDownValue;

  Attribute({this.id, this.name, this.options, this.position, this.variation, this.visible, this.dropDownValue, this.optionString});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'],
      name: json['name'],
      optionString: json['option'],
      options: json['options'] != null ? new List<String>.from(json['options']) : null,
      position: json['position'],
      variation: json['variation'],
      visible: json['visible'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['option'] = this.optionString;
    data['position'] = this.position;
    data['variation'] = this.variation;
    data['visible'] = this.visible;
    if (this.options != null) {
      data['options'] = this.options;
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? slug;

  Category({this.id, this.name, this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    return data;
  }
}

class Dimensions {
  String? height;
  String? length;
  String? width;

  Dimensions({this.height, this.length, this.width});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      height: json['height'],
      length: json['length'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['length'] = this.length;
    data['width'] = this.width;
    return data;
  }
}

class Downloads {
  String? id;
  String? name;
  String? file;

  Downloads({this.id, this.name, this.file});

  factory Downloads.fromJson(Map<String, dynamic> json) {
    return Downloads(
      id: json['id'],
      name: json['name'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['file'] = this.file;
    return data;
  }
}

class ImageModel {
  String? alt;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  int? id;
  String? name;
  String? src;

  ImageModel({this.alt, this.dateCreated, this.dateCreatedGmt, this.dateModified, this.dateModifiedGmt, this.id, this.name, this.src});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      alt: json['alt'],
      dateCreated: json['date_created'],
      dateCreatedGmt: json['date_created_gmt'],
      dateModified: json['date_modified'],
      dateModifiedGmt: json['date_modified_gmt'],
      id: json['id'],
      name: json['name'],
      src: json['src'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alt'] = this.alt;
    data['date_created'] = this.dateCreated;
    data['date_created_gmt'] = this.dateCreatedGmt;
    data['date_modified'] = this.dateModified;
    data['date_modified_gmt'] = this.dateModifiedGmt;
    data['id'] = this.id;
    data['name'] = this.name;
    data['src'] = this.src;
    return data;
  }
}
