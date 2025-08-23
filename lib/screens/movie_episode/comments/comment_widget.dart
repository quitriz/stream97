import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/add_rating_component.dart';
import 'package:streamit_flutter/components/splash_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/comments/comment_list_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../../main.dart';

// ignore: must_be_immutable
class CommentWidget extends StatefulWidget {
  static String tag = '/CommentWidget';
  final int? postId;
  String? noOfComments;
  final PostType? postType;
  final List<MovieComment> comments;

  CommentWidget({this.postId, this.noOfComments, required this.postType, required this.comments});

  @override
  CommentWidgetState createState() => CommentWidgetState();
}

class CommentWidgetState extends State<CommentWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isNotEmpty)
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.postType == PostType.VIDEO)
                Text(
                  widget.comments.length > 1 ? language.comments.capitalizeFirstLetter() : language.comment.capitalizeFirstLetter(),
                  style: primaryTextStyle(size: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  language.lblRateAndReview,
                  style: primaryTextStyle(size: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              4.width,
              Text("(${widget.noOfComments})", style: primaryTextStyle(size: 20)),
            ],
          ),
          8.height,
          SplashWidget(
            padding: EdgeInsets.all(0),
            onTap: () async {
              LiveStream().emit(PauseVideo);
              await CommentListScreen(
                showComments: widget.postType == PostType.VIDEO,
                postId: widget.postId.validate(),
              ).launch(context).then((value) {
                if (value != null && value is Map) {
                  if (value['is_update']) {
                    setState(() {});
                  }
                }
              });
            },
            backgroundColor: Colors.grey.withValues(alpha:0.1),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.comments.length,
              itemBuilder: (_, index) {
                MovieComment comment = widget.comments[index];

                return comment.commentParent == "0"
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: Text(
                              comment.commentAuthor![0].validate().toUpperCase(),
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
                                      Text(comment.commentAuthor.validate(), style: boldTextStyle(color: Colors.white)).expand(),
                                      Text(
                                        DateTime.parse(comment.commentDate.validate()).timeAgo,
                                        style: secondaryTextStyle(),
                                      ),
                                    ],
                                  ),
                                  if (widget.postType != PostType.VIDEO)
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
                                parseHtmlString(comment.commentContent.validate()),
                                style: primaryTextStyle(color: Colors.grey, size: 14),
                              ),
                            ],
                          ).expand(),
                        ],
                      ).paddingTop(10)
                    : SizedBox();
              },
              separatorBuilder: (_, index) => Divider(color: textColorPrimary, thickness: 0.1, height: 0),
            ),
          ),
          8.height,
          AddRatingComponent(
            postId: widget.postId.validate(),
            showComments: widget.postType == PostType.VIDEO,
            callForRefresh: () {
              toast(language.lbWaitForCommentApproval);
            },
          ).cornerRadiusWithClipRRect(20),
        ],
      );
    else
      return AddRatingComponent(
        postId: widget.postId.validate(),
        showComments: widget.postType == PostType.VIDEO,
        callForRefresh: () {
          toast(language.lbWaitForCommentApproval);
        },
      ).cornerRadiusWithClipRRect(20);
  }
}