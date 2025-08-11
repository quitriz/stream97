import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/settings/screens/change_password_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/language_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language!.settings, style: primaryTextStyle(size: ts_large.toInt())),
        elevation: 0,
        centerTitle: true,
        backgroundColor: context.cardColor,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 60),
        child: Column(
          children: [
            if (appStore.isLogging)
              SettingWidget(
                title: language!.changePassword,
                titleTextStyle: primaryTextStyle(color: Colors.white),
                leading: Image.asset(ic_lock, color: textSecondaryColor, height: 18),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                subTitle: language!.changePasswordText,
                onTap: () {
                  ChangePasswordScreen().launch(context);
                },
              ),
            SettingWidget(
              leading: Image.asset(ic_language, color: textSecondaryColor, height: 18),
              title: language!.language,
              subTitle: getSelectedLanguageModel()?.name.validate(),
              titleTextStyle: primaryTextStyle(color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                LanguageScreen().launch(context);
              },
            ),
            SettingWidget(
              leading: Image.asset(ic_privacy, color: textSecondaryColor, height: 18),
              title: language!.privacyPolicy,
              subTitle: language!.ourCommitmentToYour,
              titleTextStyle: primaryTextStyle(color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                launchCustomTabURL(url: privacyPolicyURL);
              },
            ),
            SettingWidget(
              leading: Image.asset(ic_document, color: textSecondaryColor, height: 18),
              title: language!.termsConditions,
              subTitle: 'Important Info Awaits: Peek Inside!',
              titleTextStyle: primaryTextStyle(color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                launchCustomTabURL(url: termsConditionURL);
              },
            ),
            SnapHelperWidget<PackageInfoData>(
              future: getPackageInfo(),
              onSuccess: (d) => SettingWidget(
                leading: Image.asset(ic_rate, color: textSecondaryColor, height: 18),
                title: language!.rateUs,
                subTitle: language!.loveItLetUsKnow,
                titleTextStyle: primaryTextStyle(color: Colors.white),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  log('$playStoreBaseURL${d.packageName}');
                  if (isAndroid)
                    launchUrl(Uri.parse('$playStoreBaseURL${d.packageName}'), mode: LaunchMode.externalApplication);
                  else if (isIOS) launchUrl(Uri.parse('$IOS_APP_LINK'), mode: LaunchMode.externalApplication);
                },
              ),
            ),
            SettingWidget(
              leading: Image.asset(ic_share, color: textSecondaryColor, height: 18),
              title: language!.shareApp,
              subTitle: language!.reachUsMore,
              titleTextStyle: primaryTextStyle(color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () async {
                if (isIOS)
                  SharePlus.instance.share(ShareParams(text: 'Share $app_name app $IOS_APP_LINK'));
                else
                  SharePlus.instance.share(ShareParams(text: 'Share $app_name app $playStoreBaseURL${await getPackageName()}'));
              },
            ),
            SnapHelperWidget<PackageInfoData>(
              future: getPackageInfo(),
              onSuccess: (d) => SettingWidget(
                leading: Image.asset(ic_about, color: textSecondaryColor, height: 18),
                title: language!.aboutUs,
                subTitle: d.versionName.validate(),
                titleTextStyle: primaryTextStyle(color: Colors.white),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  launchCustomTabURL(url: aboutUsURL);
                },
              ),
            ),
            if (appStore.isLogging)
              SettingWidget(
                leading: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                title: language!.deleteAccount,
                subTitle: language!.confirmYouWantToLeave,
                titleTextStyle: primaryTextStyle(),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () async {
                  if (appStore.userEmail != DEFAULT_EMAIL) {
                    await showConfirmDialogCustom(
                      context,
                      title: language!.areYouSureYou,
                      primaryColor: context.primaryColor,
                      negativeText: language!.no,
                      positiveText: language!.yes,
                      onAccept: (context) async {
                        await deleteUserAccount().then((value) async {
                          toast(language!.accountDeletedSuccessfully);
                          appStore.setLoading(false);
                          await FirebaseMessaging.instance.unsubscribeFromTopic('${appNameTopic}').then((v) {
                            log("${FirebaseMsgConst.topicUnSubscribed}$appNameTopic");
                          });
                          logout();
                        });
                      },
                    );
                  } else {
                    toast(language!.demoUserCanTPerformThisAction);
                  }
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: TextButton(
        onPressed: () async {
          if (appStore.isLogging) {
            showConfirmDialogCustom(
              context,
              title: language!.doYouWantToLogout,
              primaryColor: context.primaryColor,
              negativeText: language!.no,
              positiveText: language!.yes,
              onAccept: (c) async {
                await logout(isNewTask: true, context: context).then((value) {
               toast(language!.youHaveBeenLoggedOutSuccessfully);
                });
              },
            );
          } else {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              context: context,
              backgroundColor: search_edittext_color,
              builder: (BuildContext context) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: SignInScreen(),
                );
              },
            );
          }
        },
        child: Text(
          appStore.isLogging ? language!.logOut : language!.login,
          style: primaryTextStyle(color: context.primaryColor),
        ),
      ).paddingSymmetric(horizontal: 16, vertical: 20),
    );
  }
}
