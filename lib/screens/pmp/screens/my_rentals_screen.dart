import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/screens/pmp/components/rental_card_item_component.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({Key? key}) : super(key: key);

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  late Future<PayPerViewOrdersModel> future;

  ///Initialize the state
  @override
  void initState() {
    future = getRentalsList();
    super.initState();
  }

  /// Fetch rentals list from API
  Future<PayPerViewOrdersModel> getRentalsList() async {
    appStore.setLoading(true);
    rentalStore.setError(false);

    try {
      final value = await getPpvOrders(page: rentalStore.mPage);

      if (rentalStore.mPage == 1) rentalStore.clearRentalList();

      if (value.data != null && value.data!.isNotEmpty) {
        rentalStore.setLastPage(value.data!.length != postPerPage);
        rentalStore.addRentals(value.data!);
      } else {
        rentalStore.setLastPage(true);
      }

      appStore.setLoading(false);
      return PayPerViewOrdersModel(data: rentalStore.rentalList.toList());
    } catch (e) {
      rentalStore.setError(true);
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      throw e;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(language.myRentals, style: boldTextStyle()),
        surfaceTintColor: context.scaffoldBackgroundColor,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Observer(
            builder: (_) {
              if (rentalStore.isError) {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.somethingWentWrong,
                ).center();
              }

              if (rentalStore.rentalList.isEmpty && !appStore.isLoading) {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.noRentalsFound,
                ).center();
              }

              if (rentalStore.rentalList.isNotEmpty) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 60),
                  child: Column(
                    children: rentalStore.rentalList.map((rental) {
                      return RentalCardItemComponent(
                        rental: rental,
                        context: context,
                        onInvoiceTap: () {
                          /// Invoice download functionality
                          if (rental.invoiceUrl != null && rental.invoiceUrl!.isNotEmpty) {
                            downloadFile(url: rental.invoiceUrl!, fileName: rental.contentName.toString());
                          } else {
                            toast('No Invoice Available', print: true);
                          }
                        },

                        /// Navigate to Movie Detail Screen on card tap
                        onCardTap: () {
                          CommonDataListModel movieData = CommonDataListModel(id: rental.contentId, title: rental.contentName, postType: rental.contentType!);
                          MovieDetailScreen(title: rental.contentName, movieData: movieData).launch(context);
                        },
                      );
                    }).toList(),
                  ),
                );
              }

              return Offstage();
            },
          ),
          Observer(
            builder: (_) {
              if (rentalStore.mPage == 1) {
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
