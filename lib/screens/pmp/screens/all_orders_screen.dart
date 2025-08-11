import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/pmp_order_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

import 'order_detail_screen.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  ScrollController _scrollController = ScrollController();

  List<PmpOrderModel> orderList = [];
  late Future<List<PmpOrderModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getOrdersList();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage && orderList.isNotEmpty) {
          mPage++;
          future = getOrdersList();
        }
      }
    });
  }

  Future<List<PmpOrderModel>> getOrdersList() async {
    appStore.setLoading(true);

    await pmpOrders(page: mPage).then((value) {
      if (mPage == 1) orderList.clear();

      mIsLastPage = value.length != 20;
      orderList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return orderList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(language!.pastInvoices, style: boldTextStyle()),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<PmpOrderModel>>(
            future: future,
            builder: (ctx, snap) {
              if (snap.hasError) {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language!.somethingWentWrong,
                ).center();
              }
              if (snap.hasData) {
                if (snap.data.validate().isEmpty) {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: language!.noData,
                  ).center();
                } else {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 60),
                    child: Table(
                      border: TableBorder.all(color: dividerDarkColor, style: BorderStyle.solid, width: 2),
                      columnWidths: const <int, TableColumnWidth>{
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text(language!.date, style: boldTextStyle()).center().paddingSymmetric(vertical: 12),
                            Text(language!.plan, style: boldTextStyle()).center().paddingSymmetric(vertical: 12),
                            Text(language!.amount, style: boldTextStyle()).center().paddingSymmetric(vertical: 12),
                          ],
                        ),
                        ...orderList.map((e) {
                          return TableRow(
                            children: [
                              TextButton(
                                onPressed: () {
                                  OrderDetailScreen(orderDetail: e).launch(context);
                                },
                                child: Text(
                                  DateFormat(dateFormatPmp).format(DateTime.parse(e.timestamp.validate())),
                                  style: primaryTextStyle(size: 14),
                                ).center(),
                              ).paddingAll(0),
                              Text(e.membershipName.validate(), style: primaryTextStyle(size: 14)).center().paddingSymmetric(vertical: 14),
                              Text('${appStore.pmpCurrency}${e.total.validate()}', style: primaryTextStyle(size: 14)).center().paddingSymmetric(vertical: 14),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
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
    );
  }
}
