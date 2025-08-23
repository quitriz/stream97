import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/woo_commerce/product_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class WooCommerceScreen extends StatefulWidget {
  final int orderId;

  WooCommerceScreen({required this.orderId});

  @override
  _WooCommerceScreenState createState() => _WooCommerceScreenState();
}

class _WooCommerceScreenState extends State<WooCommerceScreen> {
  Future<ProductModel>? future;
  ProductModel? productData;

  int total = 0;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    future = productDetail(productID: widget.orderId).then((value) {
      productData = value;
      total = productData!.price.validate().toInt();
      setState(() {});
      return value;
    }).catchError((e) {
      throw e;
    });
  }

  Future<void> createOrderApi() async {
    Map req = {
      "currency": appStore.currencySymbol,
      "customer_id": appStore.userId,
      "payment_method": "",
      "set_paid": false,
      "status": "pending",
      "transaction_id": "",
      "line_items": [
        {"product_id": widget.orderId, "quantity": "1"}
      ],
    };

    log('Request : $req');

    appStore.setLoading(true);
    await createOrders(request: req).then((order) async {
      appStore.setLoading(false);
      if (order.paymentUrl != null && order.paymentUrl.validate().isNotEmpty) {
        await WebViewScreen(url: '${order.paymentUrl.validate()}&user_id=${appStore.userId}', title: "Payment").launch(context).then((x) {
          appStore.setLoading(true);
          getOrderDetail(id: order.id.validate()).then((value) async {
            if (value.status == 'completed') {
              await getMembershipLevelForUser(userId: appStore.userId.validate()).then((membershipPlan) {
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
    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(language.orderDetails, style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<ProductModel>(
            future: future,
            loadingWidget: LoaderWidget().center(),
            errorBuilder: (error) {
              return NoDataWidget(
                title: error.toString(),
                retryText: language.refresh,
                onRetry: () {

                },
              );
            },
            onSuccess: (data) {
              return SizedBox(
                width: context.width(),
                height: context.height(),
                child: Container(
                  width: context.width() - 32,
                  height: context.height() / 2,
                  padding: EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: context.width() - 32,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${language.product}', style: boldTextStyle(size: 22, color: colorPrimary)),
                                6.height,
                                Text(productData!.name.validate(), style: boldTextStyle()),
                                6.height,
                                Text(parseHtmlString(productData!.priceHtml.validate()), style: secondaryTextStyle(size: 16)),
                                if (productData!.categories.validate().isNotEmpty)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${language.category}: ', style: boldTextStyle(size: 14)),
                                      Wrap(
                                        children: productData!.categories!.map((e) {
                                          return Text(e.name.validate(), style: primaryTextStyle(size: 14));
                                        }).toList(),
                                      ).expand(),
                                    ],
                                  ).paddingTop(6),
                              ],
                            ),
                          ),
                          24.height,
                          Container(
                            width: context.width() - 32,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${language.cartDetails}', style: boldTextStyle(size: 22, color: colorPrimary)),
                                16.height,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${language.subtotal}: ', style: boldTextStyle(size: 14)),
                                    Text(productData!.price.validate(), style: primaryTextStyle(size: 14)),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${language.total}: ', style: boldTextStyle(size: 14)),
                                    Text(total.toString(), style: primaryTextStyle(size: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          24.height,
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: AppButton(
                          width: context.width() - 32,
                          height: 40,
                          text: '${language.checkout}',
                          color: context.primaryColor,
                          onTap: () {
                            createOrderApi();
                          },
                        ),
                      ),
                      LoaderWidget().center().visible(appStore.isLoading)
                    ],
                  ),
                ),
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
