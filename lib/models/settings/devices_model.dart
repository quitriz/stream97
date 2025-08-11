class DevicesModel {
  DevicesModel({
    this.deviceId,
    this.deviceModel,
    this.loginTime,
    this.token,
  });

  DevicesModel.fromJson(dynamic json) {
    deviceId = json['device_id'];
    deviceModel = json['device_model'];
    loginTime = json['login_time'];
    token = json['token'];
  }

  String? deviceId;
  String? deviceModel;
  String? loginTime;
  String? token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['device_id'] = deviceId;
    map['device_model'] = deviceModel;
    map['login_time'] = loginTime;
    map['token'] = token;
    return map;
  }
}
