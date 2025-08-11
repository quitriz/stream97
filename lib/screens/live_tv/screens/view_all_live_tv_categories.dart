import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../models/live_tv/live_category_list_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/common.dart';
import 'view_live_tv_category_channels.dart';

class ViewAllLiveTvCategories extends StatefulWidget {
  const ViewAllLiveTvCategories({Key? key}) : super(key: key);

  @override
  _ViewAllLiveTvCategoriesState createState() => _ViewAllLiveTvCategoriesState();
}

class _ViewAllLiveTvCategoriesState extends State<ViewAllLiveTvCategories> {
  Future<AllLiveCategoryList>? future;
  List<Data> categoryList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(true);
    future = getLiveCategoryList().then((value) {
      categoryList.clear();
      categoryList.addAll(value.data ?? []);
      setState(() {});
      appStore.setLoading(false);
      return value;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Categories', style: boldTextStyle(color: Colors.white, size: 20)),
        backgroundColor: context.scaffoldBackgroundColor,
        centerTitle: false,
        surfaceTintColor: context.scaffoldBackgroundColor,
        elevation: 0,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Stack(
        children: [
          SnapHelperWidget(
            future: future,
            loadingWidget: Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading).center()),
            errorBuilder: (p0) {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: p0,
                onRetry: () {
                  init(showLoader: true);
                },
                retryText: language!.refresh,
              ).center();
            },
            onSuccess: (AllLiveCategoryList data) {
              if (categoryList.isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language!.noDataFound,
                  onRetry: () {
                    init(showLoader: true);
                  },
                  retryText: language!.refresh,
                ).center();
              else
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: categoryList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
                    itemBuilder: (context, index) {
                      final cat = categoryList[index];
                      return GestureDetector(
                        onTap: () {
                          ViewLiveTvCategoryChannels(
                            categoryId: cat.id!,
                            categoryName: cat.name ?? '',
                          ).launch(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              cat.thumbnailImage != null && cat.thumbnailImage!.isNotEmpty
                                  ? Image.network(cat.thumbnailImage!, height: 48, width: 48)
                                  : Icon(Icons.image, size: 48, color: Colors.white54),
                              12.height,
                              Text(cat.name ?? '', style: boldTextStyle(color: Colors.white, size: 16), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
            },
          ),
          Observer(
            builder: (context) {
              return LoaderWidget().visible(appStore.isLoading);
            },
          )
        ],
      ),
    );
  }
}
