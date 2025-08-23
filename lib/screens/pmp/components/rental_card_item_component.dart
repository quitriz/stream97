import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class RentalCardItemComponent extends StatelessWidget {
  final OrderData rental;
  final BuildContext context;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onCardTap;

  const RentalCardItemComponent({Key? key, required this.rental, required this.context, this.onInvoiceTap, this.onCardTap}) : super(key: key);

  /// Format date string to a readable format
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat(dateFormatPmp).format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: this.context.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dividerDarkColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Content Image and Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Content Image
                Container(
                  width: 80,
                  height: 120,
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImageWidget(
                      url: rental.contentImage.validate().isEmpty ? default_image : rental.contentImage.validate(),
                      fit: BoxFit.cover,
                      height: 120,
                      width: 80,
                    ),
                  ),
                ),

                /// Content Details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Content Name
                        Text(
                          rental.contentName.validate(),
                          style: boldTextStyle(size: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        8.height,

                        /// Content PostType
                        Text(
                          '${language.type}: ${getPostTypeString(rental.contentType).capitalizeFirstLetter()}',
                          style: secondaryTextStyle(size: 14),
                        ),
                        4.height,

                        /// Purchase Date
                        Text(
                          '${language.purchaseDate}: ${_formatDate(rental.purchaseDate.validate())}',
                          style: secondaryTextStyle(size: 14),
                        ),
                        4.height,

                        /// Expiry Date
                        if (rental.expireAt != null &&
                            rental.expireAt!.isNotEmpty &&
                            rental.validityStatus.validate().toLowerCase() != ValidityStatus.lifetimeAccess)
                          Text(
                            '${language.expires}: ${_formatDate(rental.expireAt.validate())}',
                            style: secondaryTextStyle(size: 14),
                          ),
                        8.height,

                        /// Validity Status
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (rental.validityStatus.validate().toLowerCase() == ValidityStatus.available || rental.validityStatus.validate().toLowerCase() == ValidityStatus.lifetimeAccess)
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rental.validityStatus.validate().toUpperCase(),
                            style: TextStyle(
                              color: (rental.validityStatus.validate().toLowerCase() == ValidityStatus.available || rental.validityStatus.validate().toLowerCase() == ValidityStatus.lifetimeAccess)
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// Payment Details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.paymentStatus, style: secondaryTextStyle(size: 13)),
                      4.height,

                      ///Payment Status
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rental.status.validate() == PaymentStatus.success ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rental.status.validate() == PaymentStatus.success ? language.paid.toUpperCase() : language.unpaid.toUpperCase(),
                          style: TextStyle(
                            color: rental.status.validate() == PaymentStatus.success ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Rental Price
                  if (rental.total != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.totalAmount, style: secondaryTextStyle(size: 13)),
                        4.height,
                        Text('${appStore.pmpCurrency} ${rental.total}', style: boldTextStyle(size: 14, color: white)),
                      ],
                    ),

                  ///Invoice Button
                  InkWell(
                    onTap: onInvoiceTap,
                    child: Container(
                      margin: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.3), borderRadius: radius(4)),
                      child: TextIcon(
                        text: language.invoice,
                        textStyle: boldTextStyle(color: white, size: 14),
                        suffix: Icon(Icons.file_download_outlined, color: white, size: 14),
                      ),
                    ),
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
