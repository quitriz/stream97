class NonceModel {
  NonceModel({this.nonce});

  NonceModel.fromJson(dynamic json) {
    nonce = json['nonce'];
  }

  String? nonce;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['nonce'] = nonce;
    return map;
  }
}
