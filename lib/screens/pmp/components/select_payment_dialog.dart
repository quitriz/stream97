import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class SelectPaymentDialog extends StatefulWidget {
  final Function(int paymentMethodIndex) paymentMethod;

  const SelectPaymentDialog({required this.paymentMethod});

  @override
  State<SelectPaymentDialog> createState() => _SelectPaymentDialogState();
}

class _SelectPaymentDialogState extends State<SelectPaymentDialog> {
  int? paymentMethodIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget paymentOptionWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(paymentMethodIndex == 0 ? Icons.radio_button_checked : Icons.circle_outlined, color: context.iconColor, size: 18),
            8.width,
            Text(language!.pmpPayment, style: primaryTextStyle()),
          ],
        ).onTap(
          () {
            paymentMethodIndex = 0;
            setState(() {});
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        16.height,
        Row(
          children: [
            Icon(paymentMethodIndex == 1 ? Icons.radio_button_checked : Icons.circle_outlined, color: context.iconColor, size: 18),
            8.width,
            Text(language!.wooCommerce, style: primaryTextStyle()),
          ],
        ).onTap(
          () {
            paymentMethodIndex = 1;
            setState(() {});
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        20.height,
        AppButton(
          onTap: () async {
            if (paymentMethodIndex != null)
              widget.paymentMethod.call(paymentMethodIndex!);
            else
              toast("Please choose payment method");
          },
          width: context.width(),
          color: colorPrimary,
          splashColor: colorPrimary,
          child: Text(language!.makePayment, style: boldTextStyle(color: Colors.white)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(language!.paymentBy, style: boldTextStyle(size: 20, color: Colors.red)),
        20.height,
        paymentOptionWidget(),
      ],
    );
  }
}
