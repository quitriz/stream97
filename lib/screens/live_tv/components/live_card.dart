import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import '../../../generated/assets.dart';

class LiveTagComponent extends StatelessWidget {
  const LiveTagComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          language!.live,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  getLiveIcon() {
    try {
      return Lottie.asset(Assets.lottieLive, height: 18, repeat: true);
    } catch (e) {
      return const Icon(Icons.circle, size: 8, color: colorPrimary);
    }
  }
}
