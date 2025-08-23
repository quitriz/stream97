import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ForgetPasswordDialog extends StatefulWidget {
  const ForgetPasswordDialog({super.key});

  @override
  State<ForgetPasswordDialog> createState() => _ForgetPasswordDialogState();
}

class _ForgetPasswordDialogState extends State<ForgetPasswordDialog> {
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();

  void loginClick() async {
    if (formKey1.currentState!.validate()) {
      formKey1.currentState!.save();

      if (emailCont.text.trim().isEmpty) {
        toast(language.thisFieldIsRequired);
        return;
      }
      if (!emailCont.text.trim().validateEmail()) {
        toast(language.enterValidEmail);
        return;
      }
      hideKeyboard(context);
      finish(context);

      appStore.setLoading(true);

      await forgotPassword({'email': emailCont.text.trim()}).then((value) {
        toast(value.message.validate());
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          30.height,
          Text(language.forgotPasswordData, style: boldTextStyle(size: 18)),
          10.height,
          Text(
            'Don’t worry! it happens. please enter the email associated with your account',
            style: secondaryTextStyle(),
            textAlign: TextAlign.center,
          ),
          30.height,
          TextFormField(
            style: primaryTextStyle(),
            controller: emailCont,
            keyboardType: TextInputType.emailAddress,
            decoration: inputDecoration(
              context,
              hint: language.email,
              hintStyle: secondaryTextStyle(),
              prefixIcon: Icon(Icons.mail_outline, color: textSecondaryColorGlobal, size: 18),
            ),
            validator: (value) {
              if (value!.isEmpty) return language.thisFieldIsRequired;
              return null;
            },
            onFieldSubmitted: (s) {
              loginClick();
            },
          ),
          24.height,
          AppButton(
            onTap: () async {
              loginClick();
            },
            width: context.width(),
            color: colorPrimary,
            splashColor: colorPrimary,
            child: Text(language.submit, style: boldTextStyle(color: Colors.white)),
          ).center(),
          30.height,
        ],
      ),
    );
  }
}
