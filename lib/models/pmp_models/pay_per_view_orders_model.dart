import 'package:streamit_flutter/utils/constants.dart';

class PayPerViewOrdersModel {
  bool? status;
  String? message;
  List<OrderData>? data;

  PayPerViewOrdersModel({
    this.status,
    this.message,
    this.data,
  });

  factory PayPerViewOrdersModel.fromJson(Map<String, dynamic> json) => PayPerViewOrdersModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<OrderData>.from(json["data"]!.map((x) => OrderData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class OrderData {
  int? id;
  String? code;
  int? userId;
  String? inAppPurchaseIdentifier;
  int? membershipId;
  String? membershipName;
  int? contentId;
  String? contentName;
  String? contentImage;
  PostType? contentType;
  String? validityStatus;
  String? expireAt;
  String? invoiceUrl;
  String? paymentStatus;
  String? purchaseDate;
  Billing? billing;
  num? subtotal;
  int? tax;
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

  OrderData({
    this.id,
    this.code,
    this.userId,
    this.inAppPurchaseIdentifier,
    this.membershipId,
    this.membershipName,
    this.contentId,
    this.contentName,
    this.contentImage,
    this.contentType,
    this.validityStatus,
    this.expireAt,
    this.invoiceUrl,
    this.paymentStatus,
    this.purchaseDate,
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
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    id: json["id"],
    code: json["code"],
    userId: json["user_id"],
    inAppPurchaseIdentifier: json["in_app_purchase_identifier"],
    membershipId: json["membership_id"],
    membershipName: json["membership_name"],
    contentId: json["content_id"],
    contentName: json["content_name"],
    contentImage: json["content_image"],
    contentType: json['content_type'] != null
        ? json['content_type'] == 'movie'
        ? PostType.MOVIE
        : json['content_type'] == 'episode'
        ? PostType.EPISODE
        : json['content_type'] == 'tv_show'
        ? PostType.TV_SHOW
        : json['content_type'] == 'video'
        ? PostType.VIDEO
        : PostType.NONE
        : PostType.NONE,
    validityStatus: json["validity_status"],
    expireAt: json["expire_at"]?.toString(),
    invoiceUrl: json["invoice_url"],
    paymentStatus: json["payment_status"],
    purchaseDate: json["purchase_date"],
    billing: json["billing"] == null ? null : Billing.fromJson(json["billing"]),
    subtotal: json["subtotal"],
    tax: json["tax"],
    total: json["total"],
    paymentType: json["payment_type"],
    cardType: json["card_type"],
    accountNumber: json["account_number"],
    expirationMonth: json["expiration_month"],
    expirationYear: json["expiration_year"],
    status: json["status"],
    gateway: json["gateway"],
    gatewayEnvironment: json["gateway_environment"],
    paymentTransactionId: json["payment_transaction_id"],
    subscriptionTransactionId: json["subscription_transaction_id"],
    timestamp: json["timestamp"],
    affiliateId: json["affiliate_id"],
    affiliateSubId: json["affiliate_sub_id"],
    notes: json["notes"],
    checkoutId: json["checkout_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "user_id": userId,
    "in_app_purchase_identifier": inAppPurchaseIdentifier,
    "membership_id": membershipId,
    "membership_name": membershipName,
    "content_id": contentId,
    "content_name": contentName,
    "content_image": contentImage,
    "content_type": contentType,
    "validity_status": validityStatus,
    "expire_at": expireAt,
    "invoice_url": invoiceUrl,
    "payment_status": paymentStatus,
    "purchase_date": purchaseDate,
    "billing": billing?.toJson(),
    "subtotal": subtotal,
    "tax": tax,
    "total": total,
    "payment_type": paymentType,
    "card_type": cardType,
    "account_number": accountNumber,
    "expiration_month": expirationMonth,
    "expiration_year": expirationYear,
    "status": status,
    "gateway": gateway,
    "gateway_environment": gatewayEnvironment,
    "payment_transaction_id": paymentTransactionId,
    "subscription_transaction_id": subscriptionTransactionId,
    "timestamp": timestamp,
    "affiliate_id": affiliateId,
    "affiliate_sub_id": affiliateSubId,
    "notes": notes,
    "checkout_id": checkoutId,
  };
}

class Billing {
  String? name;
  String? street;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? phone;

  Billing({
    this.name,
    this.street,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
  });

  factory Billing.fromJson(Map<String, dynamic> json) => Billing(
    name: json["name"],
    street: json["street"],
    city: json["city"],
    state: json["state"],
    zip: json["zip"],
    country: json["country"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "street": street,
    "city": city,
    "state": state,
    "zip": zip,
    "country": country,
    "phone": phone,
  };
}