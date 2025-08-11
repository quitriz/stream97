import 'package:nb_utils/nb_utils.dart';

class MembershipModel {
  MembershipModel({
    this.id,
    this.subscriptionId,
    this.name,
    this.description,
    this.confirmation,
    this.expirationNumber,
    this.expirationPeriod,
    this.allowSignups,
    this.initialPayment,
    this.billingAmount,
    this.cycleNumber,
    this.cyclePeriod,
    this.billingLimit,
    this.trialAmount,
    this.trialLimit,
    this.codeId,
    this.startdate,
    this.enddate,
    this.categories,
    this.isInitial,
    this.checkoutUrl,
    this.productId,
    this.inAppActivePlanId,
    this.playStorePlanIdentifier,
    this.appStorePlanIdentifier,
  });

  MembershipModel.fromJson(dynamic json) {
    id = json['ID'];
    id = json['id'];
    subscriptionId = json['subscription_id'];
    name = json['name'];
    description = json['description'];
    confirmation = json['confirmation'];
    expirationNumber = json['expiration_number'];
    expirationPeriod = json['expiration_period'];
    allowSignups = json['allow_signups'];
    initialPayment = json['initial_payment'];
    billingAmount = json['billing_amount'];
    cycleNumber = json['cycle_number'];
    cyclePeriod = json['cycle_period'];
    billingLimit = json['billing_limit'];
    trialAmount = json['trial_amount'];
    trialLimit = json['trial_limit'];
    codeId = json['code_id'];
    startdate = json['startdate'];
    isInitial = json['is_initial'];
    checkoutUrl = json['checkout_url'];
    productId = json['product_id'];
    enddate = json['enddate'].toString().toInt();
    playStorePlanIdentifier = json["google_in_app_purchase_identifier"] != null ? json["google_in_app_purchase_identifier"] : '';
    appStorePlanIdentifier = json["apple_in_app_purchase_identifier"] != null ?json["apple_in_app_purchase_identifier"] : '';
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories!.add(v);
      });
    }
  }

  String? id;
  String? subscriptionId;
  String? name;
  String? description;
  String? confirmation;
  String? expirationNumber;
  String? expirationPeriod;
  String? allowSignups;
  num? initialPayment;
  num? billingAmount;
  String? cycleNumber;
  String? cyclePeriod;
  String? billingLimit;
  num? trialAmount;
  String? trialLimit;
  String? codeId;
  String? startdate;
  int? enddate;
  List<dynamic>? categories;
  bool? isInitial;
  String? checkoutUrl;
  int? productId;

  ///in App Purchase

  String? inAppActivePlanId;
  String? playStorePlanIdentifier;
  String? appStorePlanIdentifier;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID'] = id;
    map['id'] = id;
    map['subscription_id'] = subscriptionId;
    map['name'] = name;
    map['description'] = description;
    map['confirmation'] = confirmation;
    map['expiration_number'] = expirationNumber;
    map['expiration_period'] = expirationPeriod;
    map['allow_signups'] = allowSignups;
    map['initial_payment'] = initialPayment;
    map['billing_amount'] = billingAmount;
    map['cycle_number'] = cycleNumber;
    map['cycle_period'] = cyclePeriod;
    map['billing_limit'] = billingLimit;
    map['trial_amount'] = trialAmount;
    map['trial_limit'] = trialLimit;
    map['code_id'] = codeId;
    map['startdate'] = startdate;
    map['enddate'] = enddate;
    map['is_initial'] = isInitial;
    map['checkout_url'] = checkoutUrl;
    map['product_id'] = productId;
    map['active_plan_id'] = inAppActivePlanId;
    map['google_in_app_purchase_identifier'] = playStorePlanIdentifier;
    map['google_in_app_purchase_identifier'] = appStorePlanIdentifier;

    if (categories != null) {
      map['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
