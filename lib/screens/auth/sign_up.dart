import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_account_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../../utils/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';
  final VoidCallback? redirectTo;

  SignUpScreen({this.redirectTo});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController controller = ScrollController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool isFirstTime = true;

  Future<void> doSignUp() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Map req = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "user_email": emailController.text,
        "user_login": userNameController.text,
        "user_pass": passwordController.text,
      };

      appStore.setLoading(true);

      await register(req).then((value) async {
        Map req = {
          "username": emailController.text,
          "password": passwordController.text,
        };

        await token(req).then((value) async {
          await setValue(PASSWORD, passwordController.text);
          addDeviceInfo();
          finish(context);

          if (appStore.isMembershipEnabled)
            MyAccountScreen(fromRegistration: true).launch(context);
          else
            HomeScreen().launch(context, isNewTask: true);

          appStore.setLoading(false);
        }).catchError((e) {
          appStore.setLoading(false);

          toast(e.toString());
        });
      }).catchError((e) {
        appStore.setLoading(false);

        toast(e.toString());
      });
    } else {
      isFirstTime = false;
      setState(() {});
    }
  }

  Future<void> addDeviceInfo() async {
    String id = '';
    String model = '';

    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      id = info.identifierForVendor.validate();
      model = info.model.validate();
    }

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      id = info.id.validate();
      model = info.model.validate();
    }

    DateTime currentPhoneDate = DateTime.now(); //DateTime
    int timeStamp = currentPhoneDate.millisecondsSinceEpoch;

    Map request = {
      "device_id": id,
      "device_model": model,
      "last_login_time": "$timeStamp",
      "login_token": getStringAsync(TOKEN)
    };
    addDevices(request).then((value) {
      appStore.setLoginDevice(id);
    }).catchError(onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: controller,
            shrinkWrap: false,
            slivers: <Widget>[
              Theme(
                data: AppTheme.darkTheme,
                child: SliverAppBar(
                  leading: BackButton(),
                  systemOverlayStyle: defaultSystemUiOverlayStyle(context),
                  expandedHeight: context.height() / 2 - 48,
                  backgroundColor: context.scaffoldBackgroundColor,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return FlexibleSpaceBar(
                        background: SizedBox(
                          height: context.height() / 2 - 32,
                          child: Stack(
                            children: [
                              Container(
                                height: context.height() * 0.60,
                                width: context.width(),
                                alignment: Alignment.bottomCenter,
                                decoration: boxDecorationDefault(
                                  borderRadius: BorderRadius.zero,
                                  color: context.scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: List.generate(
                                        10,
                                        (index) =>
                                            Colors.black.withAlpha(index * 32)),
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(ic_signIn3),
                                    colorFilter: ColorFilter.mode(
                                        colorPrimary.withValues(alpha: 0.6),
                                        BlendMode.dstOver),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 60,
                  ),
                  child: Form(
                    key: formKey,
                    autovalidateMode: isFirstTime
                        ? AutovalidateMode.disabled
                        : AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.height,
                        Text(language.createYourAccountFor,
                            style: boldTextStyle(size: 24),
                            textAlign: TextAlign.center),
                        8.height,
                        Text(language.registerAndExploreOur,
                            style: secondaryTextStyle(color: Colors.white)),
                        24.height,
                        AppTextField(
                          focus: firstNameFocus,
                          nextFocus: lastNameFocus,
                          controller: firstNameController,
                          cursorColor: colorPrimary,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            return value!.isEmpty
                                ? errorThisFieldRequired
                                : null;
                          },
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: inputDecoration(
                            context,
                            hint: language.firstName,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.person_2_outlined,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                          textFieldType: TextFieldType.NAME,
                        ).paddingBottom(spacing_standard_new),
                        AppTextField(
                          focus: lastNameFocus,
                          nextFocus: userNameFocus,
                          textFieldType: TextFieldType.USERNAME,
                          controller: lastNameController,
                          cursorColor: colorPrimary,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            return value!.isEmpty
                                ? errorThisFieldRequired
                                : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            context,
                            hint: language.lastName,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.person_2_outlined,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                        ).paddingBottom(spacing_standard_new),
                        AppTextField(
                          focus: userNameFocus,
                          nextFocus: emailFocus,
                          textFieldType: TextFieldType.USERNAME,
                          controller: userNameController,
                          cursorColor: colorPrimary,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            context,
                            hint: language.username,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.person_2_outlined,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                        ).paddingBottom(spacing_standard_new),
                        AppTextField(
                          focus: emailFocus,
                          nextFocus: passFocus,
                          textFieldType: TextFieldType.USERNAME,
                          controller: emailController,
                          cursorColor: colorPrimary,
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            context,
                            hint: language.email,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.mail_outline,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            } else if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          onChanged: (value) {},
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                        ).paddingBottom(spacing_standard_new),
                        AppTextField(
                          textFieldType: TextFieldType.PASSWORD,
                          controller: passwordController,
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                          cursorColor: colorPrimary,
                          focus: passFocus,
                          nextFocus: confirmPasswordFocus,
                          textInputAction: TextInputAction.next,
                          suffixPasswordInvisibleWidget: Icon(
                              Icons.visibility_off,
                              color: colorPrimary,
                              size: 18),
                          suffixPasswordVisibleWidget: Icon(Icons.visibility,
                              color: colorPrimary, size: 18),
                          decoration: inputDecoration(
                            context,
                            hint: language.password,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.lock,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                          isPassword: true,
                          isValidationRequired: true,
                          errorThisFieldRequired: language.thisFieldIsRequired,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return language.thisFieldIsRequired;
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ).paddingBottom(spacing_standard_new),
                        AppTextField(
                          cursorColor: colorPrimary,
                          textFieldType: TextFieldType.PASSWORD,
                          textStyle: TextStyle(
                              fontSize: ts_normal,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color),
                          focus: confirmPasswordFocus,
                          validator: (value) {
                            if (value!.isEmpty) return errorThisFieldRequired;
                            return passwordController.text == value
                                ? null
                                : language.passWordNotMatch;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (arg) {
                            doSignUp();
                          },
                          suffixPasswordInvisibleWidget: Icon(
                              Icons.visibility_off,
                              color: colorPrimary,
                              size: 18),
                          suffixPasswordVisibleWidget: Icon(Icons.visibility,
                              color: colorPrimary, size: 18),
                          decoration: inputDecoration(
                            context,
                            hint: language.confirmPassword,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.lock,
                                color: textSecondaryColorGlobal, size: 18),
                          ),
                        ),
                        30.height,
                        AppButton(
                          width: context.width(),
                          textColor: colorPrimary,
                          color: colorPrimary,
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(language.signUp,
                              style: primaryTextStyle(
                                  size: ts_normal.toInt(),
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .color)),
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius:
                                new BorderRadius.circular(spacing_control),
                            side: BorderSide(color: colorPrimary),
                          ),
                          onTap: () {
                            hideKeyboard(context);
                            doSignUp();
                          },
                        ).paddingOnly(
                          left: spacing_standard_new,
                          right: spacing_standard_new,
                          bottom: spacing_standard_new,
                        ),
                        GestureDetector(
                          onTap: () {
                            finish(context);
                          },
                          child: RichTextWidget(
                            list: <TextSpan>[
                              TextSpan(
                                text: language.alreadyAMember + ' ',
                                style: secondaryTextStyle(
                                    fontFamily:
                                        GoogleFonts.nunito().fontFamily),
                              ),
                              TextSpan(
                                text: language.login,
                                style: secondaryTextStyle(
                                    color: context.primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontFamily:
                                        GoogleFonts.nunito().fontFamily),
                              ),
                            ],
                          ),
                        ).center(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(appStore.isLoading).center(),
          ),
        ],
      ),
    );
  }
}
