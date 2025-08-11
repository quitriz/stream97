class ValidateTokenModel {
  ValidateTokenModel({
    this.message,
    this.status,
    this.statusCode,
  });

  ValidateTokenModel.fromJson(dynamic json) {
    message = json['message'];
    status = json['status'];
    statusCode = json['status_code'];
  }

  String? message;
  bool? status;
  int? statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['status'] = status;
    map['status_code'] = statusCode;
    return map;
  }
}
