class Subscription {
  String? subscriptionPlanId;
  String? startDate;
  String? expirationDate;
  String? status;
  String? trailStatus;
  String? subscriptionPlanName;
  String? billingAmount;
  String? trialEnd;
  String? playStorePlanIdentifier;
  String? appStorePlanIdentifier;

  Subscription({
    this.subscriptionPlanId,
    this.startDate,
    this.expirationDate,
    this.status,
    this.trailStatus,
    this.subscriptionPlanName,
    this.billingAmount,
    this.trialEnd,
    this.playStorePlanIdentifier,
    this.appStorePlanIdentifier,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionPlanId: json['subscription_plan_id'],
      startDate: json['start_date'],
      expirationDate: json['expiration_date'],
      status: json['status'],
      trailStatus: json['trail_status'] ?? "",
      subscriptionPlanName: json['subscription_plan_name'],
      billingAmount: json['billing_amount'] != null ? json['billing_amount'].toString() : "",
      trialEnd: json['trial_end'] != null ? json['trial_end'].toString() : "",
      playStorePlanIdentifier : json["google_in_app_purchase_identifier"] != null ? json["google_in_app_purchase_identifier"] : '',
      appStorePlanIdentifier :json["apple_in_app_purchase_identifier"] != null ?json["apple_in_app_purchase_identifier"] : '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscription_plan_id'] = this.subscriptionPlanId;
    data['start_date'] = this.startDate;
    data['expiration_date'] = this.expirationDate;
    data['status'] = this.status;
    data['trail_status'] = this.trailStatus;
    data['subscription_plan_name'] = this.subscriptionPlanName;
    data['billing_amount'] = this.billingAmount;
    data['trial_end'] = this.trialEnd;
    data['google_in_app_purchase_identifier'] = playStorePlanIdentifier;
    data['google_in_app_purchase_identifier'] = appStorePlanIdentifier;
    return data;
  }
}
