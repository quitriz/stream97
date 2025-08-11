import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/home/movie_grid_widget.dart';
import 'package:streamit_flutter/screens/home/recent_search_list.dart';
import 'package:streamit_flutter/screens/search/search_card_component.dart';
import 'package:streamit_flutter/screens/search/voice_search_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../components/loader_widget.dart';

class SearchFragment extends StatefulWidget {
  static String tag = '/SearchFragment';

  @override
  SearchFragmentState createState() => SearchFragmentState();
}

class SearchFragmentState extends State<SearchFragment> {
  List<CommonDataListModel> movies = [];
  List<RecentSearchListModel> recentList = [];

  Future<List<CommonDataListModel>>? future;
  Future<List<RecentSearchListModel>>? futureRecent;

  TextEditingController searchController = TextEditingController();

  int page = 1;

  bool isLastPage=false;

  StreamController<String> searchStream = StreamController();

  @override
  void initState() {
    super.initState();
    init();
    searchStream.stream.debounce(Duration(seconds: 2)).listen((s) {
      page = 1;
      init();
      setState(() {});
    });
  }

  Future<void> init({bool isLoading = true}) async {
    if (searchController.text.isEmpty) {
      futureRecent = recentListFetch(recentList: recentList);
    } else {
      future = searchMovie(searchController.text, page: page, movies: movies, isLoading: isLoading);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('', color: Colors.black, textColor: Colors.white),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          init(isLoading: false);
          setState(() {});
          return await 2.seconds.delay;
        },
        child: Stack(
          children: [
            AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onNextPage: () {
                if (!isLastPage) {
                  setState(() {
                    page++;
                  });
                  init();
                }
              },
              children: [
                Container(
                  color: search_edittext_color,
                  padding: EdgeInsets.only(left: spacing_standard_new, right: spacing_standard),
                  child: Row(
                    children: <Widget>[
                      Image.asset(ic_search, fit: BoxFit.fitHeight, color: textColorSecondary, height: 16, width: 16),
                      8.width,
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
                          decoration: InputDecoration(
                            hintText: language!.searchMoviesTvShowsVideos,
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.titleSmall!.color,
                            ),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          onChanged: (s) {
                            searchStream.add(s);
                          },
                          onFieldSubmitted: (s) {
                            page = 1;
                            if (s.isNotEmpty) init();
                            ///todo : Add to recent list api call

                            addRecent(s);

                            setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          page = 1;
                          searchController.clear();
                          hideKeyboard(context);
                          init();
                          setState(() {});
                        },
                        icon: Icon(Icons.cancel, color: colorPrimary, size: 20),
                      ).visible(searchController.text.isNotEmpty),
                      IconButton(
                        onPressed: () {
                          VoiceSearchScreen().launch(context).then((value) {
                            if (value != null) {
                              searchController.text = value;
                              addRecent(value);

                              setState(() {});
                              hideKeyboard(context);
                              page = 1;
                              init();
                            }
                          });
                        },
                        icon: Icon(Icons.keyboard_voice_outlined, color: textColorSecondary, size: 20),
                      ).visible(searchController.text.isEmpty),
                    ],
                  ),
                ),
                searchController.text.isEmpty
                    ? SnapHelperWidget(future: futureRecent,
                    errorBuilder: (e) {
                      return SizedBox(
                        height: context.height() * 0.7,
                        child: NoDataWidget(
                          title: language!.pleaseLoginToSearch,
                          retryText: language!.login,
                          onRetry: () {
                            SignInScreen().launch(context);
                          },
                        ),
                      );
                    },
                    loadingWidget: Offstage(),
                    onSuccess: (data){
                      return RecentSearchList(data,

                          onItemTap: (value){
                        searchController.text = value;
                        page = 1;
                        init();
                        setState(() {});
                      }, onRemoveRecent: (int ) {
                          init();
                          setState(() {});
                        },);
                    })
                    :
                SnapHelperWidget<List<CommonDataListModel>>(
                  future: future,
                  errorBuilder: (e) {
                    return SizedBox(
                      height: context.height() * 0.7,
                      child: NoDataWidget(
                        imageWidget: noDataImage(),
                        title: e.toString(),
                        onRetry: () {
                          page = 1;
                          init();
                          setState(() {});
                        },
                      ),
                    );
                  },
                  loadingWidget: Offstage(),
                  onSuccess: (data) {
                    if (data.validate().isEmpty) {
                      return SizedBox(
                        height: context.height() * 0.7,
                        child: NoDataWidget(
                          imageWidget: noDataImage(),
                          title: language!.noContentFound,
                          subTitle: language!.theContentHasNot,
                        ).center(),
                      );
                    }

                    if (searchController.text.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          16.height,
                          Text(
                            language!.resultFor + " \'" + searchController.text + "\'",
                            style: primaryTextStyle(size: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).paddingSymmetric(horizontal: 16),
                          SearchCardComponent(list: data),
                        ],
                      );
                    } else {
                      return MovieGridList(data.validate());
                    }
                  },
                ),
              ],
            ).makeRefreshable,
            Observer(
              builder: (_) {
                if (page == 1) {
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