class BillingModel {
  BillingModel({
    this.name,
    this.street,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
  });

  BillingModel.fromJson(dynamic json) {
    name = json['name'];
    street = json['street'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
    phone = json['phone'];
  }

  String? name;
  String? street;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? phone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['street'] = street;
    map['city'] = city;
    map['state'] = state;
    map['zip'] = zip;
    map['country'] = country;
    map['phone'] = phone;
    return map;
  }
}
