import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/blog/wp_post_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/blog/components/blog_card_component.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  ScrollController _controller = ScrollController();

  List<WpPostResponse> blogList = [];
  late Future<List<WpPostResponse>> future;
  TextEditingController searchController = TextEditingController();

  List<String> tags = [];
  String category = '';
  int mPage = 1;
  bool mIsLastPage = false;
  bool isChange = false;
  bool isError = false;
  bool hasShowClearTextIcon = false;

  @override
  void initState() {
    future = getBlogs();

    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          setState(() {});

          future = getBlogs();
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        hasShowClearTextIcon = false;
        setState(() {});
      }
    });
  }

  void showClearTextIcon() {
    if (!hasShowClearTextIcon) {
      hasShowClearTextIcon = true;
      setState(() {});
    } else {
      return;
    }
  }

  Future<List<WpPostResponse>> getBlogs() async {
    appStore.setLoading(true);

    await getBlogList(page: mPage, searchText: searchController.text.trim()).then((value) {
      if (mPage == 1) blogList.clear();
      mIsLastPage = value.length != postPerPage;
      blogList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return blogList;
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    future = getBlogs();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language!.blogs, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            Container(
              width: context.width() - 32,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius(defaultRadius)),
              child: AppTextField(
                controller: searchController,
                textFieldType: TextFieldType.USERNAME,
                onFieldSubmitted: (text) {
                  mPage = 1;
                  future = getBlogs();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: language!.search,
                  hintStyle: secondaryTextStyle(),
                  prefixIcon: Image.asset(
                    ic_search,
                    height: 16,
                    width: 16,
                    fit: BoxFit.cover,
                    color: textColorThird,
                  ).paddingAll(16),
                  suffixIcon: hasShowClearTextIcon
                      ? IconButton(
                    icon: Icon(Icons.cancel, color: textColorThird, size: 18),
                    onPressed: () {
                      hideKeyboard(context);
                      hasShowClearTextIcon = false;
                      searchController.clear();

                      mPage = 1;
                      getBlogs();
                      setState(() {});
                    },
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: context.height() - 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder<List<WpPostResponse>>(
                    future: future,
                    builder: (ctx, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: NoDataWidget(
                            imageWidget: noDataImage(),
                            title: isError ? language!.somethingWentWrong : language!.noData,
                          ),
                        );
                      }

                      if (snap.hasData) {
                        if (snap.data.validate().isEmpty) {
                          return Center(
                            child: NoDataWidget(
                              imageWidget: noDataImage(),
                              title: isError ? language!.somethingWentWrong : 'No Blogs Found for ${searchController.text}',
                            ),
                          );
                        } else {
                          return AnimatedListView(
                            slideConfiguration: SlideConfiguration(
                              delay: 80.milliseconds,
                              verticalOffset: 300,
                            ),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                            itemCount: blogList.length,
                            itemBuilder: (context, index) {
                              WpPostResponse data = blogList[index];
                              return BlogCardComponent(data: data);
                            },
                          );
                        }
                      }
                      return Offstage();
                    },
                  ),
                  Observer(
                    builder: (_) {
                      if (appStore.isLoading) {
                        if (mPage != 1) {
                          return Positioned(
                            bottom: 10,
                            child: LoadingDotsWidget(),
                          );
                        } else {
                          return LoaderWidget().center();
                        }
                      } else {
                        return Offstage();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}