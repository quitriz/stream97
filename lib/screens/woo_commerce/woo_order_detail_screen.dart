import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/woo_commerce/order_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  OrderModel orderDetails;

  OrderDetailScreen({required this.orderDetails});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isChange = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) finish(context, isChange);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, isChange);
            },
          ),
          titleSpacing: 0,
          title: Text(language.orderDetails, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${language.orderStatus}:', style: boldTextStyle()),
                      Text(
                        widget.orderDetails.status.validate().capitalizeFirstLetter(),
                        style: boldTextStyle(color: context.primaryColor, size: 18),
                      ),
                    ],
                  ),
                  16.height,
                  Container(
                    decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius(defaultAppButtonRadius)),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('${language.orderNumber}:', style: primaryTextStyle()),
                            8.width,
                            Text(widget.orderDetails.id.validate().toString(), style: primaryTextStyle()).expand(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text('${language.date}:', style: primaryTextStyle()),
                            8.width,
                            Text(formatDate(widget.orderDetails.dateCreated.validate().toString()), style: primaryTextStyle()).expand(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text('${language.email}:', style: primaryTextStyle()),
                            8.width,
                            Text(appStore.userEmail.validate(), style: primaryTextStyle()).expand(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Text('${language.products}:', style: boldTextStyle()),
                  16.height,
                  Container(
                    decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius(defaultAppButtonRadius)),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.orderDetails.lineItems!.length,
                          itemBuilder: (ctx, index) {
                            return Row(
                              children: [
                                Text(
                                  '${widget.orderDetails.lineItems![index].name.validate()} * ${widget.orderDetails.lineItems![index].quantity.validate()}',
                                  style: primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).expand(),
                                Text('${widget.orderDetails.lineItems![index].total.validate()}', style: secondaryTextStyle()),
                              ],
                            ).paddingSymmetric(vertical: 6);
                          },
                        ),
                        16.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${language.total}:', style: boldTextStyle()),
                            Text(widget.orderDetails.total.validate(), style: primaryTextStyle()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
            Observer(builder: (ctx) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
        bottomNavigationBar: widget.orderDetails.needsPayment.validate()
            ? AppButton(
                width: context.width() - 32,
                text: language.makePayment,
                color: context.primaryColor,
                onTap: () async {
                  if (widget.orderDetails.paymentUrl != null && widget.orderDetails.paymentUrl.validate().isNotEmpty) {
                    await WebViewScreen(url: widget.orderDetails.paymentUrl.validate(), title: "Payment").launch(context).then((x) {
                      appStore.setLoading(true);
                      getOrderDetail(id: widget.orderDetails.id.validate()).then((value) async {
                        isChange = widget.orderDetails.status != value.status;
                        widget.orderDetails = value;
                        setState(() {});
                        if (value.status == 'completed') {
                          await getMembershipLevelForUser(userId: appStore.userId.validate()).then((membershipPlan) {
                            appStore.setLoading(false);
                            if (membershipPlan != null) {
                              HomeScreen().launch(context, isNewTask: true);
                            }
                          }).catchError((e) {
                            appStore.setLoading(false);
                            log('Error: ${e.toString()}');
                          });
                        } else {
                          appStore.setLoading(false);
                          toast('Your Order is ${value.status}');
                        }
                      }).catchError((e) {
                        appStore.setLoading(false);
                        log('Error: ${e.toString()}');
                      });
                    });
                  } else {
                    appStore.setLoading(false);
                    toast('Payment Url not found');
                  }
                },
              ).paddingAll(16)
            : Offstage(),
      ),
    );
  }
}