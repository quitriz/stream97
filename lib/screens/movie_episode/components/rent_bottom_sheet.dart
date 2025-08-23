import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/movie_episode/components/selection_button_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/html_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class RentBottomSheet extends StatelessWidget {
  final MovieData movie;
  final String genre;
  final VoidCallback? onRentTap;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onUpgradeTap;
  final bool showSubscribeButton;
  final bool showUpgradeButton;

  const RentBottomSheet({Key? key, required this.movie, required this.genre, this.onRentTap, this.onSubscribeTap, this.onUpgradeTap, this.showSubscribeButton = false, this.showUpgradeButton = false})
      : super(key: key);

  static void show(BuildContext context,
      {required MovieData movie,
      required String genre,
      VoidCallback? onRentTap,
      VoidCallback? onSubscribeTap,
      VoidCallback? onUpgradeTap,
      bool showSubscribeButton = false,
      bool showUpgradeButton = false}) {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RentBottomSheet(
        movie: movie,
        genre: genre,
        onRentTap: onRentTap,
        onSubscribeTap: onSubscribeTap,
        onUpgradeTap: onUpgradeTap,
        showSubscribeButton: showSubscribeButton,
        showUpgradeButton: showUpgradeButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Scrollable content area
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  20.height,

                  /// Movie info row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Movie poster
                      CachedImageWidget(url: movie.image.validate(), height: 160, width: 120, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                      16.width,

                      /// Movie details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Movie title
                            Text(
                              parseHtmlString(movie.title.validate()),
                              style: primaryTextStyle(size: 24, weight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            8.height,

                            /// Movie metadata
                            Row(
                              children: [
                                if (movie.publishDate.validate().isNotEmpty) ...[
                                  Text(getYearFromDate(movie.publishDate.validate()), style: secondaryTextStyle(size: 16, color: white)),
                                  if (movie.runTime.validate().isNotEmpty) ...[
                                    Text(" • ", style: secondaryTextStyle(size: 14)),
                                    Text(movie.runTime.validate(), style: secondaryTextStyle(size: 16)),
                                  ],
                                ],
                              ],
                            ),
                            8.height,

                            /// Movie genre and tags
                            if (genre.isNotEmpty) ...[
                              Text(genre, style: secondaryTextStyle(size: 14)),
                            ],
                            8.height,
                            if (movie.tag.validate().isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: movie.tag.validate().map((tag) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: cardColor, borderRadius: radius(6)),
                                    child: Text(tag.validate(), style: secondaryTextStyle(size: 14)),
                                  );
                                }).toList(),
                              ),
                            ],
                            8.height,
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  /// Movie Validity
                  Row(
                    children: [
                      Text("${language.validity}: ", style: primaryTextStyle(size: 16, weight: FontWeight.w600)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: cardColor, borderRadius: radius(6)),
                        child: Text(
                          movie.validity.validate().toString() == '0'
                              ? language.lifetimeAccess
                              : movie.validity.validate().toString() + " " + (movie.validity.validate() == 1 ? language.day : language.days),
                          style: boldTextStyle(size: 16, color: rentColor),
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 8),
                  16.height,

                  /// Rent Info
                  Text(language.info, style: primaryTextStyle(size: 18, weight: FontWeight.bold)).paddingSymmetric(horizontal: 8),
                  HtmlWidget(postContent: movie.rentInfo, fontSize: 14, color: textSecondaryColorGlobal),
                ],
              ),
            ),
          ),

          /// Selection button (fixed at bottom)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: showSubscribeButton || showUpgradeButton
                ? Row(
                    children: [
                      Expanded(
                        child: SelectionButton(
                          rentPriceWidget: rentalPriceWidget(discountedPrice: movie.discountedPrice.validate(), price: movie.price.validate()),
                          color: rentButtonColor,
                          onTap: () {
                            Navigator.pop(context);
                            onRentTap?.call();
                          },
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: SelectionButton(
                          text: showUpgradeButton ? language.upgradePlan : language.subscribeNow,
                          color: colorPrimary,
                          onTap: () {
                            Navigator.pop(context);
                            if (showUpgradeButton) {
                              onUpgradeTap?.call();
                            } else {
                              onSubscribeTap?.call();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : SelectionButton(
                    rentPriceWidget: rentalPriceWidget(discountedPrice: movie.discountedPrice.validate(), price: movie.price.validate()),
                    color: rentButtonColor,
                    onTap: () {
                      Navigator.pop(context);
                      onRentTap?.call();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}