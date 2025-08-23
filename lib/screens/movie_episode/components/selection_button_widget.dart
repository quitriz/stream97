import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/movie_episode/components/rent_bottom_sheet.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../../utils/common.dart';

class SelectionButton extends StatelessWidget {
  final String? text;
  final Widget? rentPriceWidget;
  final Color color;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final TextStyle? textStyle;

  const SelectionButton({Key? key, this.text, this.rentPriceWidget, required this.color, this.onTap, this.height = 45, this.width, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? context.width(),
      decoration: BoxDecoration(color: color, borderRadius: radius(4)),
      child: (rentPriceWidget ?? Text(text ?? '', style: textStyle ?? boldTextStyle(color: Colors.white))).center(),
    ).onTap(onTap);
  }
}

class SelectionButtonsWidget extends StatelessWidget {
  final MovieData movie;
  final String genre;
  final bool isTrailerPlaying;
  final bool isUpcoming;
  final VoidCallback? onStreamNow;
  final VoidCallback? onRent;
  final VoidCallback? onSubscribe;
  final VoidCallback? onUpgrade;

  const SelectionButtonsWidget({
    Key? key,
    required this.movie,
    required this.genre,
    this.isTrailerPlaying = false,
    this.isUpcoming = false,
    this.onStreamNow,
    this.onRent,
    this.onSubscribe,
    this.onUpgrade,
  }) : super(key: key);

  /// Determines if the upgrade button should be shown based on the user's current plan
  bool get _shouldShowUpgrade {
    if (movie.requiredPlan.validate().isEmpty || appStore.subscriptionPlanId.isEmpty) {
      return false;
    }

    /// Parse plan IDs and compare
    try {
      final currentPlanId = int.tryParse(appStore.subscriptionPlanId) ?? 0;
      for (final requiredPlan in movie.requiredPlan!) {
        final requiredPlanId = int.tryParse(requiredPlan.toString()) ?? 0;
        if (currentPlanId < requiredPlanId) {
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Navigate to Membership Plans screen with required plan IDs
  void _navigateToMembershipPlans(BuildContext context) {
    if (!appStore.isLogging) {
      SignInScreen().launch(context);
      return;
    }
    MembershipPlansScreen(requiredPlanIds: movie.requiredPlan).launch(context);
  }

  /// Show the rent bottom sheet with options for renting, subscribing, or upgrading
  void _showRentBottomSheet(
    BuildContext context, {
    bool showSubscribeButton = false,
    bool showUpgradeButton = false,
  }) {
    RentBottomSheet.show(
      context,
      movie: movie,
      genre: genre,
      onRentTap: onRent,
      onSubscribeTap: () => _navigateToMembershipPlans(context),
      onUpgradeTap: () => _navigateToMembershipPlans(context),
      showSubscribeButton: showSubscribeButton,
      showUpgradeButton: showUpgradeButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isTrailerPlaying && !isUpcoming && movie.userHasAccess.validate())
          SelectionButton(text: language.streamNow, color: colorPrimary, textStyle: boldTextStyle(color: Colors.white), onTap: onStreamNow),
        /// Rent Button (PPV)
        if (movie.purchaseType == PurchaseType.ppv && movie.isRent == true && movie.userHasAccess == false && appStore.isMembershipEnabled)
          SelectionButton(
            rentPriceWidget: rentalPriceWidget(
              discountedPrice: movie.discountedPrice.validate(),
              price: movie.price.validate(),
            ),
            color: rentButtonColor,
            onTap: () => _showRentBottomSheet(context, showSubscribeButton: false),
          ),
        /// Subscribe/Upgrade Button (Plan only)
        if (movie.purchaseType == PurchaseType.plan &&
            movie.isRent.validate() &&
            movie.requiredPlan.validate().isNotEmpty &&
            appStore.subscriptionPlanId != movie.requiredPlan.toString() &&
            movie.userHasAccess == false && appStore.isMembershipEnabled)
          SelectionButton(
            text: _shouldShowUpgrade ? language.upgradeToWatch : language.subscribeToWatch,
            color: colorPrimary,
            onTap: _shouldShowUpgrade ? () => _navigateToMembershipPlans(context) : () => _navigateToMembershipPlans(context),
          ),

        /// Rent or Subscribe Button (Anyone)
        if (movie.purchaseType == PurchaseType.anyone &&
            movie.isRent.validate() &&
            movie.requiredPlan.validate().isNotEmpty &&
            appStore.subscriptionPlanId != movie.requiredPlan.toString() &&
            movie.userHasAccess == false && appStore.isMembershipEnabled)
          SelectionButton(
            text: _shouldShowUpgrade ? language.rentOrUpgradeToWatch : language.rentOrSubscribeToWatch,
            color: colorPrimary,
            onTap: () => _showRentBottomSheet(context, showSubscribeButton: !_shouldShowUpgrade, showUpgradeButton: _shouldShowUpgrade),
          ),
      ],
    );
  }
}
