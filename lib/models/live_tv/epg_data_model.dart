class EpgDataModel {
  bool? status;
  String? message;
  Data? data;

  EpgDataModel({
    this.status,
    this.message,
    this.data,
  });

  factory EpgDataModel.fromJson(Map<String, dynamic> json) {
    return EpgDataModel(
      status: true,
      message: 'Success',
      data: Data.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  DateTime? date;
  List<EpgChannel>? channels;

  Data({
    this.date,
    this.channels,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    channels: json["channels"] == null ? [] : List<EpgChannel>.from(json["channels"]!.map((x) => EpgChannel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "channels": channels == null ? [] : List<dynamic>.from(channels!.map((x) => x.toJson())),
  };
}

class EpgChannel {
  int? id;
  String? title;
  String? thumbnailImage;
  List<Program>? programs;
  String? userTimezone;
  String? userDate;
  bool? hasEpgData;

  EpgChannel({
    this.id,
    this.title,
    this.thumbnailImage,
    this.programs,
    this.userTimezone,
    this.userDate,
    this.hasEpgData,
  });

  factory EpgChannel.fromJson(Map<String, dynamic> json) => EpgChannel(
        id: json["id"],
        title: json["title"],
        thumbnailImage: json["thumbnail_image"],
        programs: json["programs"] == null ? [] : List<Program>.from(json["programs"]!.map((x) => Program.fromJson(x))),
        userTimezone: json["user_timezone"],
        userDate: json["user_date"],
        hasEpgData: json["has_epg_data"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumbnail_image": thumbnailImage,
        "programs": programs == null ? [] : List<dynamic>.from(programs!.map((x) => x.toJson())),
        "user_timezone": userTimezone,
        "user_date": userDate,
        "has_epg_data": hasEpgData,
      };
}

class Program {
  String? id;
  String? title;
  String? description;
  int? startTime;
  int? endTime;
  String? thumbnail;
  String? category;
  String? startTimeFormatted;
  String? endTimeFormatted;
  String? dateFormatted;
  bool? isCurrent;
  String? userStartTime;
  String? userEndTime;
  String? userTimezone;

  Program({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.thumbnail,
    this.category,
    this.startTimeFormatted,
    this.endTimeFormatted,
    this.dateFormatted,
    this.isCurrent,
    this.userStartTime,
    this.userEndTime,
    this.userTimezone,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        thumbnail: json["thumbnail"],
        category: json["category"],
        startTimeFormatted: json["start_time_formatted"],
        endTimeFormatted: json["end_time_formatted"],
        dateFormatted: json["date_formatted"],
        isCurrent: json["is_current"],
        userStartTime: json["user_start_time"],
        userEndTime: json["user_end_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "start_time": startTime,
        "end_time": endTime,
        "thumbnail": thumbnail,
        "category": category,
      };
}
