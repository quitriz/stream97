import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/add_rating_component.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/comment_model.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class CommentListScreen extends StatefulWidget {
  final int postId;
  final bool showComments;
  final Function()? callForRefresh;

  CommentListScreen({Key? key, required this.postId, this.callForRefresh, this.showComments = false});

  @override
  State<CommentListScreen> createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  final TextEditingController mainCommentCont = TextEditingController();

  List<CommentModel> commentList = [];
  late Future<List<CommentModel>> future;

  List<String> tags = [];
  String category = '';

  int mPage = 1;
  bool mIsLastPage = false;

  bool isChange = false;
  bool isError = false;

  @override
  void initState() {
    future = getBlogs();
    super.initState();
  }

  Future<List<CommentModel>> getBlogs() async {
    appStore.setLoading(true);

    await getComments(postId: widget.postId, page: mPage, commentPerPage: postPerPage).then((value) {
      if (mPage == 1) commentList.clear();
      mIsLastPage = value.length != postPerPage;
      commentList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return commentList;
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
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: appBarWidget(
          widget.showComments ? language.comments.capitalizeFirstLetter() : language.lblRateAndReview,
          color: Colors.transparent,
          textColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            FutureBuilder<List<CommentModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: language.somethingWentWrong,
                    subTitle: language.theContentHasNot,
                  ).center();
                }

                if (snap.hasData) {
                  if (snap.data.validate().isEmpty) {
                    return NoDataWidget(
                      imageWidget: noDataImage(),
                      title: language.noCommentsAdded,
                      subTitle: language.letUsKnowWhat,
                    ).paddingSymmetric(horizontal: 40).center();
                  } else {
                    return AnimatedListView(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 150),
                      itemCount: commentList.length,
                      itemBuilder: (_, index) {
                        CommentModel comment = commentList[index];

                        return comment.parent == 0
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: Text(
                                      comment.authorName![0].validate().toUpperCase(),
                                      style: boldTextStyle(color: colorPrimary, size: 20),
                                    ).center(),
                                  ),
                                  16.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(comment.authorName.validate(), style: boldTextStyle(color: Colors.white)),
                                              Text(
                                                DateTime.parse(comment.date.validate()).timeAgo,
                                                style: secondaryTextStyle(),
                                              ),
                                            ],
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          ),
                                          if (!widget.showComments)
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 16),
                                                4.width,
                                                Text(comment.rating.validate().toString(), style: secondaryTextStyle()).paddingOnly(right: 8),
                                              ],
                                            )
                                        ],
                                      ),
                                      4.height,
                                      Text(
                                        parseHtmlString(comment.content!.rendered.validate()),
                                        style: primaryTextStyle(color: Colors.grey, size: 14),
                                      ),
                                    ],
                                  ).expand(),
                                ],
                              ).paddingTop(14)
                            : SizedBox();
                      },
                      onNextPage: () {
                        if (!mIsLastPage && !appStore.isLoading) {
                          mPage++;
                          future = getBlogs();
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
                    bottom: 150,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
            Positioned(
              bottom: context.navigationBarHeight,
              child: mIsLoggedIn
                  ? AddRatingComponent(
                      postId: widget.postId,
                      showComments: widget.showComments,
                      callForRefresh: () {
                        toast(language.lbWaitForCommentApproval);
                        widget.callForRefresh?.call();
                        finish(context);
                      },
                    )
                  : InkWell(
                      onTap: () {
                        SignInScreen(
                          redirectTo: () {
                            setState(() {});
                          }
                        ).launch(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: context.width(),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(color: colorPrimary.withValues(alpha:0.2), blurRadius: 8.0, offset: Offset(0, -8)),
                          ],
                        ),
                        child: Text(language.loginToAddComment, style: boldTextStyle(color: context.primaryColor)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
