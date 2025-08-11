class BaseResponseModel {
  String? message;
  String? statusCode;
  bool? success;
  String? code;

  BaseResponseModel({
    this.message,
    this.statusCode,
    this.success,
    this.code,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      message: json['message'],
      statusCode: json['statusCode'],
      success: json['status'],
      code: json['code'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.success;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
