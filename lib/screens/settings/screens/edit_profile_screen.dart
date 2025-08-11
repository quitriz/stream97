import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  XFile? image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    firstNameController.text = getStringAsync(NAME);
    lastNameController.text = getStringAsync(LAST_NAME);
    emailController.text = appStore.userEmail.validate();
  }

  Future<void> getImage() async {
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100).then((value) {
      image = value;
      setState(() {});
    }).catchError((error) {
      toast(errorSomethingWentWrong);
      log(error);
    });
  }

  Future<void> save(BuildContext context) async {
    hideKeyboard(context);
    updateProfile(firstName: firstNameController.text.trim(), latName: lastNameController.text.trim(), image: image).then((value) {
      finish(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language!.editProfile, color: Colors.transparent, textColor: Colors.white, elevation: 0),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        color: colorPrimary,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: spacing_standard_new,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(51)),
                        child: image != null
                            ? Image.file(File(image!.path), height: 95, width: 95, fit: BoxFit.cover)
                            : appStore.userProfileImage.validate().isNotEmpty
                                ? CachedImageWidget(url: appStore.userProfileImage.validate(), height: 95, width: 95, fit: BoxFit.cover)
                                : CachedImageWidget(url: appStore.userProfileImage.validate(), width: 95, height: 95, fit: BoxFit.cover),
                      ),
                      TextButton(
                        onPressed: () {
                          getImage();
                        },
                        child: Text(language!.changeAvatar, style: secondaryTextStyle(size: ts_small.toInt())),
                      ),
                    ],
                  ).paddingOnly(top: 16),
                ).center(),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppTextField(
                        controller: firstNameController,
                        nextFocus: lastNameFocusNode,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(hint: language!.firstName, suffixIcon: Icons.person_outline),
                        textStyle: primaryTextStyle(color: textColorPrimary),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: lastNameController,
                        focus: lastNameFocusNode,
                        nextFocus: emailFocusNode,
                        textFieldType: TextFieldType.NAME,
                        errorThisFieldRequired: errorThisFieldRequired,
                        decoration: inputDecoration(hint: language!.lastName, suffixIcon: Icons.person_outline),
                        textStyle: primaryTextStyle(color: textColorPrimary),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: emailController,
                        textFieldType: TextFieldType.EMAIL,
                        focus: emailFocusNode,
                        decoration: inputDecoration(hint: language!.email, suffixIcon: Icons.mail_outline),
                        textStyle: primaryTextStyle(color: textColorThird),
                        enabled: false,
                      ).paddingBottom(spacing_standard_new),
                    ],
                  ),
                ).paddingOnly(left: 16, right: 16, top: 36),
                AppButton(
                  width: context.width(),
                  text: language!.save,
                  color: colorPrimary,
                  onTap: () {
                    if (appStore.userEmail != DEFAULT_EMAIL) {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        save(context);
                      }
                    } else {
                      toast("Demo user can't perfom this action.");
                    }
                  },
                ).paddingOnly(top: 30, left: 18, right: 18, bottom: 30)
              ],
            ),
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
