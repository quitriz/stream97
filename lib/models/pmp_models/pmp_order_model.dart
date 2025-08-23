import 'billing_model.dart';

class PmpOrderModel {
  int? id;
  String? code;
  int? userId;
  String? inAppPurchaseIdentifier;
  int? membershipId;
  String? membershipName;
  BillingModel? billing;
  num? subtotal;
  num? tax;
  num? total;
  String? paymentType;
  String? cardType;
  String? accountNumber;
  String? expirationMonth;
  String? expirationYear;
  String? status;
  String? gateway;
  String? gatewayEnvironment;
  String? paymentTransactionId;
  String? subscriptionTransactionId;
  int? timestamp;
  int? affiliateId;
  String? affiliateSubId;
  String? notes;
  int? checkoutId;
  String? invoiceUrl;

  PmpOrderModel({
    this.id,
    this.code,
    this.userId,
    this.inAppPurchaseIdentifier,
    this.membershipId,
    this.membershipName,
    this.billing,
    this.subtotal,
    this.tax,
    this.total,
    this.paymentType,
    this.cardType,
    this.accountNumber,
    this.expirationMonth,
    this.expirationYear,
    this.status,
    this.gateway,
    this.gatewayEnvironment,
    this.paymentTransactionId,
    this.subscriptionTransactionId,
    this.timestamp,
    this.affiliateId,
    this.affiliateSubId,
    this.notes,
    this.checkoutId,
    this.invoiceUrl,
  });

  PmpOrderModel.fromJson(dynamic json) {
    id = json['id'];
    code = json['code'];
    userId = json['user_id'];
    membershipId = json['membership_id'];
    membershipName = json['membership_name'];
    billing = json['billing'] != null ? BillingModel.fromJson(json['billing']) : null;
    subtotal = json['subtotal'];
    tax = json['tax'];
    total = json['total'];
    paymentType = json['payment_type'];
    cardType = json['card_type'];
    accountNumber = json['account_number'];
    expirationMonth = json['expiration_month'];
    expirationYear = json['expiration_year'];
    status = json['status'];
    gateway = json['gateway'];
    gatewayEnvironment = json['gateway_environment'];
    paymentTransactionId = json['payment_transaction_id'];
    subscriptionTransactionId = json['subscription_transaction_id'];
    timestamp = json['timestamp'];
    affiliateId = json['affiliate_id'];
    affiliateSubId = json['affiliate_sub_id'];
    notes = json['notes'];
    checkoutId = json['checkout_id'];
    invoiceUrl = json["invoice_url"];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['code'] = code;
    map['user_id'] = userId;
    map['membership_id'] = membershipId;
    map['membership_name'] = membershipName;
    if (billing != null) {
      map['billing'] = billing!.toJson();
    }
    map['subtotal'] = subtotal;
    map['tax'] = tax;
    map['total'] = total;
    map['payment_type'] = paymentType;
    map['card_type'] = cardType;
    map['account_number'] = accountNumber;
    map['expiration_month'] = expirationMonth;
    map['expiration_year'] = expirationYear;
    map['status'] = status;
    map['gateway'] = gateway;
    map['gateway_environment'] = gatewayEnvironment;
    map['payment_transaction_id'] = paymentTransactionId;
    map['subscription_transaction_id'] = subscriptionTransactionId;
    map['timestamp'] = timestamp;
    map['affiliate_id'] = affiliateId;
    map['affiliate_sub_id'] = affiliateSubId;
    map['notes'] = notes;
    map['checkout_id'] = checkoutId;
    map['invoice_url'] = invoiceUrl;
    return map;
  }
}
