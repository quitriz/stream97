import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/splash_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/add_rating_component.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/review_list.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ReviewWidget extends StatefulWidget {
  final String postType;
  final int? postId;
  final Function callReviewList;

  ReviewWidget(
      {super.key,
      required this.postType,
      required this.postId,
      required this.callReviewList});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  void showEditReviewDialog(BuildContext context, ReviewModel review) {
    TextEditingController commentController =
        TextEditingController(text: review.rateContent);
    double currentRating = review.rate.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cardColor)),
          backgroundColor: context.cardColor,
          titlePadding:
              EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          title: Text(language!.editReview, style: primaryTextStyle()),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: commentController,
                style: secondaryTextStyle(),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: language!.editYourReview,
                  hintStyle: secondaryTextStyle(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              12.height,
              Theme(
                data: ThemeData(
                  primaryColor: colorPrimary,
                  unselectedWidgetColor: colorPrimary,
                ),
                child: RatingBarWidget(
                  onRatingChanged: (rating) {
                    currentRating = rating;
                  },
                  rating: currentRating,
                  inActiveColor: colorPrimary,
                  allowHalfRating: false,
                  size: 20,
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(8),
                side: BorderSide(color: Colors.white),
              ),
              color: context.cardColor,
              onTap: () {
                finish(context);
              },
              child: Text(
                language!.cancel,
                style: primaryTextStyle(color: Colors.white, size: 14),
              ),
            ),
            8.width,
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(8),
                side: BorderSide(color: colorPrimary),
              ),
              color: colorPrimary,
              onTap: () async {
                if (commentController.text.trim().isEmpty &&
                    currentRating == 0) {
                  toast(language!.pleaseProvideRating);
                  return;
                }
                appStore.setLoading(true);
                finish(context);
                await Future.delayed(Duration(milliseconds: 300));

                var request = {
                  'post_id': widget.postId,
                  'user_name': getStringAsync(USERNAME),
                  'user_email': getStringAsync(USER_EMAIL),
                  'rating': currentRating,
                  'cm_details': commentController.text.trim(),
                  'rate_id': review.rateId
                };

                addReview(request, widget.postType.toString().toLowerCase())
                    .then((value) {
                  widget.callReviewList();
                  appStore.setLoading(false);
                  currentRating = 0;
                  commentController.clear();
                }).catchError((error) {
                  appStore.setLoading(false);
                  toast(language!.pleaseTryAgain);
                });
              },
              child: Text(
                language!.update,
                style: boldTextStyle(color: Colors.white, size: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  bool hasUserAlreadyReviewed() {
    int currentUserId = getIntAsync(USER_ID);
    return appStore.reviewList.any((review) => review.userId == currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (appStore.reviewList.isNotEmpty)
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 18, color: colorPrimary),
                      8.width,
                      widget.postType == PostType.VIDEO
                          ? Text(
                              appStore.reviewList.length > 1
                                  ? language!.comments.capitalizeFirstLetter()
                                  : language!.comment.capitalizeFirstLetter(),
                              style: boldTextStyle(size: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              language!.lblRateAndReview,
                              style: boldTextStyle(size: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      4.width,
                      Text("(${appStore.reviewList.length})",
                          style:
                              primaryTextStyle(size: 16, color: colorPrimary)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ReviewList(
                        postType: widget.postType,
                      ).launch(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 28),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(language!.viewAll, style: secondaryTextStyle()),
                  ).visible(appStore.reviewList.length > 3),
                ],
              ),
              8.height,
              Divider(color: Colors.grey.withValues(alpha: 0.3), height: 1),
              8.height,
              SplashWidget(
                backgroundColor: Colors.transparent,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final review = appStore.reviewList[index];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedImageWidget(
                                  url: review.userImage.validate(),
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover)
                              .cornerRadiusWithClipRRect(14),
                          12.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.postType != PostType.VIDEO
                                      ? Row(
                                          children: [
                                            Text(review.userName,
                                                style: boldTextStyle(
                                                    color: Colors.white,
                                                    size: 14)),
                                            8.width,
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.star,
                                                      color: Colors.amber,
                                                      size: 14),
                                                  2.width,
                                                  Text(review.rate.toString(),
                                                      style: secondaryTextStyle(
                                                          size: 12)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(review.userName,
                                          style: boldTextStyle(
                                              color: Colors.white, size: 14)),
                                  // Updated timestamp display with better formatting
                                  Container(
                                    margin: EdgeInsets.only(right: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time_outlined,
                                            size: 12, color: Colors.grey),
                                        4.width,
                                        Text(
                                          convertToAgo(review.date),
                                          style: secondaryTextStyle(
                                              size: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              2.height,
                              Text(review.rateContent,
                                  style: primaryTextStyle(
                                      color: Colors.grey, size: 13)),
                              6.height,
                              if (review.userId == getIntAsync(USER_ID))
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit button
                                    InkWell(
                                      onTap: () {
                                        showEditReviewDialog(context, review);
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Colors.blue
                                              .withValues(alpha: 0.1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                size: 12,
                                                color: Colors.blue[300]),
                                            4.width,
                                            Text(language!.edit,
                                                style: secondaryTextStyle(
                                                    size: 10,
                                                    color: Colors.blue[300])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    8.width,
                                    InkWell(
                                      onTap: () {
                                        showConfirmDialogCustom(
                                          context,
                                          title: language!
                                              .areYouSureYouWantToDeleteThisReview,
                                          primaryColor: colorPrimary,
                                          positiveText: language!.delete,
                                          negativeText: language!.cancel,
                                          onAccept: (value) {
                                            var request = {
                                              'post_id': widget.postId,
                                              'user_id': getIntAsync(USER_ID)
                                                  .toString(),
                                              'rate_id': review.rateId
                                            };
                                            appStore.setLoading(true);
                                            addReview(
                                                    request,
                                                    widget.postType
                                                        .toString()
                                                        .toLowerCase(),
                                                    method: "delete")
                                                .then((value) {
                                              toast(value.message);
                                              widget.callReviewList();
                                              appStore.setLoading(false);
                                            }).catchError((error) {
                                              appStore.setLoading(false);
                                            });
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.delete_outline,
                                                size: 12,
                                                color: Colors.red[300]),
                                            4.width,
                                            Text(language!.delete,
                                                style: secondaryTextStyle(
                                                    size: 10,
                                                    color: Colors.red[300])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ).expand(),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, index) => Divider(
                    color: Colors.grey.withValues(alpha: 0.2),
                    thickness: 1,
                    height: 8,
                  ),
                  itemCount: appStore.reviewList.length > 3
                      ? 3
                      : appStore.reviewList.length,
                ),
                onTap: () {},
              ),
              12.height,
              AddRatingComponent(
                postType: widget.postType,
                postId: widget.postId.validate(),
                showComments: widget.postType == PostType.VIDEO,
                callForRefresh: () {
                  widget.callReviewList();
                },
              ).visible(!hasUserAlreadyReviewed()),
            ],
          ),
        );
      else
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: AddRatingComponent(
            postType: widget.postType,
            postId: widget.postId.validate(),
            showComments: widget.postType == PostType.VIDEO,
            callForRefresh: () {
              widget.callReviewList();
            },
          ),
        );
    });
  }
}
