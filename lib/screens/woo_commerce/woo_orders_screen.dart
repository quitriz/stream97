import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/woo_commerce/order_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/woo_commerce/woo_order_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> orderList = [];
  late Future<List<OrderModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getOrders();
    super.initState();
  }

  Future<List<OrderModel>> getOrders({String? status}) async {
    appStore.setLoading(true);

    await getOrderList(page: mPage).then((value) {
      if (mPage == 1) orderList.clear();

      mIsLastPage = value.length != postPerPage;
      orderList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      throw e;
    });

    return orderList;
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    future = getOrders();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          titleSpacing: 0,
          title: Text(language!.pastInvoices, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            FutureBuilder<List<OrderModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: snap.error.toString(),
                    onRetry: () {
                      future = getOrders();
                    },
                  ).center();
                } else if (snap.hasData) {
                  if (orderList.isEmpty && !isError) {
                    return NoDataWidget(
                      imageWidget: noDataImage(),
                      title: language!.noData,
                    ).center();
                  } else if (isError) {
                    return NoDataWidget(
                      imageWidget: noDataImage(),
                      title: snap.error.toString(),
                      onRetry: () {
                        future = getOrders();
                      },
                    ).center();
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(
                        delay: 80.milliseconds,
                        verticalOffset: 300,
                      ),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            OrderDetailScreen(orderDetails: orderList[index]).launch(context).then((value) {
                              if (value ?? false) {
                                mPage = 1;
                                getOrders();
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius(defaultAppButtonRadius)),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('${language!.plan}: ', style: primaryTextStyle()),
                                        Text(orderList[index].lineItems.validate()[0].name.validate(), style: boldTextStyle(color: context.primaryColor)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('${language!.orderNumber}: ', style: primaryTextStyle(size: 14)),
                                        Text(orderList[index].id.validate().toString(), style: secondaryTextStyle()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('${language!.date}: ', style: primaryTextStyle(size: 14)),
                                        Text(formatDate(orderList[index].dateCreated.validate()), style: secondaryTextStyle()),
                                      ],
                                    ),
                                    10.height,
                                    Row(
                                      children: [
                                        Text('${language!.total}: ', style: boldTextStyle()),
                                        Text(orderList[index].total.validate(), style: primaryTextStyle()),
                                      ],
                                    ),
                                  ],
                                ),
                                Align(
                                  child: Container(
                                    decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                                    child: Text(orderList[index].status.validate().capitalizeFirstLetter(), style: secondaryTextStyle(color: Colors.white)),
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  ),
                                  alignment: Alignment.topRight,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          future = getOrders();
                        }
                      },
                    );
                  }
                }
                return Offstage();
              },
            ),
            Observer(
              builder: (_) {
                if (mPage == 1) {
                  return LoaderWidget().center().visible(appStore.isLoading);
                } else {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
