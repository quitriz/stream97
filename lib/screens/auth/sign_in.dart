import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/components/forget_password_dialog.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/auth/sign_up.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../../utils/app_theme.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';
  final VoidCallback? redirectTo;

  SignInScreen({this.redirectTo});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  ScrollController controller = ScrollController();

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent, delayInMilliSeconds: 500);
    init();
  }

  Future<void> init() async {
    if (appStore.doRemember) {
      emailController.text = getStringAsync(SharePreferencesKey.LOGIN_EMAIL);
      passwordController.text = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);
    } else if (await isIqonicProduct) {
      emailController.text = DEFAULT_EMAIL;
      passwordController.text = DEFAULT_PASS;
      setState(() {});
    }
  }

  Future<void> doSignIn(BuildContext context) async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map req = {
        "username": emailController.text,
        "password": passwordController.text,
      };

      hideKeyboard(context);
      appStore.setLoading(true);

      await token(req).then((res) async {
        toast("You’re logged in. Let’s get started!");
        appStore.setLoading(false);
        userStore.setLoginEmail(emailController.text);
        userStore.setPassword(passwordController.text);
        setState(() {});

        await setValue(PASSWORD, passwordController.text);
        addDeviceInfo();
        if (widget.redirectTo != null) {
          widget.redirectTo?.call();
          finish(context);
        } else {
          HomeScreen().launch(context, isNewTask: true);
        }
      }).catchError((e) async {
        toast(e.toString());
        log(e.toString());
        appStore.setLoading(false);
        setState(() {});
        await Future.delayed(Duration(seconds: 1));
        FocusScope.of(context).requestFocus(passFocus);
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

    Map request = {"device_id": id, "device_model": model, "last_login_time": "$timeStamp", "login_token": getStringAsync(TOKEN)};
    addDevices(request).then((value) {
      appStore.setLoginDevice(id);
    }).catchError(onError);
  }

  Future<void> onForgotPasswordClicked(BuildContext context) async {
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: search_edittext_color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: ForgetPasswordDialog().paddingAll(16),
        );
      },
    );
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
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
                    builder: (BuildContext context, BoxConstraints constraints) {
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
                                    colors: List.generate(10, (index) => Colors.black.withAlpha(index * 32)),
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(ic_signIn1),
                                    colorFilter: ColorFilter.mode(colorPrimary.withValues(alpha: 0.6), BlendMode.dstOver),
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
                    top: 16,
                    bottom: 30,
                  ),
                  child: Form(
                    key: formKey,
                    autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(language.welcomeBack, style: boldTextStyle(size: 24)),
                        8.height,
                        Text(language.youHaveBeenMissed, style: secondaryTextStyle()),
                        24.height,
                        AppTextField(
                          textFieldType: TextFieldType.USERNAME,
                          controller: emailController,
                          decoration: inputDecoration(
                            context,
                            hint: language.email + ' / ' + language.username,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.mail_outline, color: textSecondaryColorGlobal, size: 18),
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          isValidationRequired: true,
                          textInputAction: TextInputAction.next,
                          focus: emailFocus,
                          nextFocus: passFocus,
                          errorThisFieldRequired: language.thisFieldIsRequired,
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.PASSWORD,
                          controller: passwordController,
                          textStyle: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
                          cursorColor: colorPrimary,
                          focus: passFocus,
                          textInputAction: TextInputAction.done,
                          suffixPasswordInvisibleWidget: Icon(
                            Icons.visibility_off,
                            size: 18,
                            color: textSecondaryColorGlobal,
                          ),
                          suffixPasswordVisibleWidget: Icon(
                            Icons.visibility,
                            size: 18,
                            color: textSecondaryColorGlobal,
                          ),
                          decoration: inputDecoration(
                            context,
                            hint: language.password,
                            hintStyle: secondaryTextStyle(),
                            prefixIcon: Icon(Icons.lock, color: textSecondaryColorGlobal, size: 18),
                          ),
                          isPassword: true,
                          isValidationRequired: true,
                          errorThisFieldRequired: language.thisFieldIsRequired,
                        ).paddingBottom(spacing_standard_new),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Row(
                                children: [
                                  Observer(
                                    builder: (_) => IconButton(
                                  icon: Icon(appStore.doRemember ? Icons.check_box : Icons.check_box_outline_blank, color: colorPrimary),
                                      onPressed: () {
                                    appStore.setRemember(!appStore.doRemember);
                                      },
                                    ),
                                  ),
                              Text(language.rememberMe, style: secondaryTextStyle()).onTap(() {
                                    appStore.setRemember(!appStore.doRemember);
                                  }),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  language.forgotPasswordData,
                              style: secondaryTextStyle(color: context.primaryColor, fontStyle: FontStyle.italic),
                            ).paddingSymmetric(vertical: spacing_standard_new, horizontal: spacing_standard).onTap(() {
                                  onForgotPasswordClicked(context);
                                }),
                              ),
                            ]),
                        AppButton(
                          width: context.width(),
                          child: Text(language.login, style: boldTextStyle()),
                          color: colorPrimary,
                          onTap: () {
                            doSignIn(context);
                          },
                        ),
                        16.height,
                        GestureDetector(
                          onTap: () {
                            SignUpScreen().launch(context);
                          },
                          child: RichTextWidget(
                            list: <TextSpan>[
                              TextSpan(
                                text: language.dontHaveAnAccount + ' ',
                                style: secondaryTextStyle(fontFamily: GoogleFonts.nunito().fontFamily),
                              ),
                              TextSpan(
                                text: language.signUp,
                                style: secondaryTextStyle(color: context.primaryColor, decoration: TextDecoration.underline, fontFamily: GoogleFonts.nunito().fontFamily),
                              ),
                            ],
                          ),
                        ),
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