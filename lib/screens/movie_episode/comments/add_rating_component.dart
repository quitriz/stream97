import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class AddRatingComponent extends StatefulWidget {
  final int postId;
  final String? postType;
  final bool showComments;
  final Function()? callForRefresh;

  AddRatingComponent({required this.postId, this.callForRefresh, this.showComments = false, this.postType});

  @override
  _AddRatingComponentState createState() => _AddRatingComponentState();
}

class _AddRatingComponentState extends State<AddRatingComponent> {
  double selectedRating = 0;
  TextEditingController mainCommentCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> add() async {
    int currentUserId = getIntAsync(USER_ID);

    bool hasAlreadyReviewed = appStore.reviewList.any((review) => review.userId == currentUserId);

    if (hasAlreadyReviewed) {
      toast(language!.youHaveAlreadySubmittedReview);
      return;
    }

    if (mainCommentCont.text.trim().isEmpty && selectedRating == 0) {
      toast(language!.pleaseProvideRating);
      return;
    }

    appStore.setLoading(true);
    var request = {
      'post_id': widget.postId,
      'user_name': getStringAsync(USERNAME),
      'user_email': getStringAsync(USER_EMAIL),
      'rating': selectedRating,
      'cm_details': mainCommentCont.text.trim(),
    };

    addReview(request, widget.postType.toString().toLowerCase()).then((value) {
      toast(value.message);
      widget.callForRefresh?.call();
      appStore.setLoading(false);
      selectedRating = 0;
      setState(() {});
      mainCommentCont.clear();
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> postComment() async {
    appStore.setLoading(true);

    await buildComment(
      content: mainCommentCont.text.trim(),
      rating: selectedRating,
      postId: widget.postId,
      postType: widget.postType,
    ).then((value) {
      appStore.setLoading(false);
      selectedRating = 0;
      setState(() {});
      mainCommentCont.clear();
      widget.callForRefresh?.call();
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: BoxDecoration(
        color: search_edittext_color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          12.height,
          if (!widget.showComments)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language!.lblPleaseRateUs, style: primaryTextStyle(size: 14)),
                8.height,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: RatingBarWidget(
                    onRatingChanged: (rating) {
                      selectedRating = rating;
                      setState(() {});
                    },
                    activeColor: selectedRating.toInt().getRatingBarColor(),
                    inActiveColor: ratingBarColor,
                    rating: selectedRating,
                    size: 22,
                  ),
                ),
                12.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          AppTextField(
            controller: mainCommentCont,
            textFieldType: TextFieldType.MULTILINE,
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            textStyle: primaryTextStyle(color: textColorPrimary),
            errorThisFieldRequired: errorThisFieldRequired,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 8, bottom: 8),
              hintText: widget.showComments ? language!.addAComment : language!.lblAddYourReview,
              hintStyle: primaryTextStyle(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: colorPrimary),
                onPressed: () {
                  hideKeyboard(context);
                  if (selectedRating == 0) {
                    toast(language!.pleaseSelectRatingBeforeSubmittingYourReview);
                    return;
                  }
                  if (appStore.isLogging)
                    add();
                  else
                    SignInScreen(
                      redirectTo: () {
                        setState(() {});
                      },
                    ).launch(context);
                },
              ).paddingOnly(right: 8),
              border: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
            ),
          ).paddingSymmetric(horizontal: 16),
        ],
      ),
    );
  }
}
