import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/splash_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../../utils/common.dart';
import '../../../utils/constants.dart';

class ReviewList extends StatelessWidget {
  final String postType;
  const ReviewList({super.key,required this.postType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews",style: primaryTextStyle(color: textColorPrimary),),
      ),
      body: Column(
        children: [
          SplashWidget(
            backgroundColor: Colors.transparent,
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final review = appStore.reviewList[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedImageWidget(url: review.userImage.validate(), height: 30, width: 30, fit: BoxFit.cover).cornerRadiusWithClipRRect(20),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (postType != PostType.VIDEO)
                                Row(
                                  children: [
                                    Text(review.userName, style: boldTextStyle(color: Colors.white, size: 16)),
                                    10.width,
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    4.width,
                                    Text(review.rate.toString(), style: secondaryTextStyle()).paddingOnly(right: 8),
                                  ],
                                ),
                              Text(convertToAgo(review.date), style: secondaryTextStyle()),
                            ],
                          ),
                          4.height,
                          Text(review.rateContent, style: primaryTextStyle(color: Colors.grey, size: 14)),
                          5.height,
                        ],
                      ).expand(),
                    ],
                  ).paddingTop(10);
                },
                separatorBuilder: (_, index) => Divider(color: textColorPrimary, thickness: 0.1, height: 0),
                itemCount:appStore.reviewList.length),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
