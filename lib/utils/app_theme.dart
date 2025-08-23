import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appBackground,
    splashColor: navigationBackground,
    primaryColor: colorPrimary,
    primaryColorDark: colorPrimaryDark,
    hoverColor: colorPrimary.withValues(alpha: 0.1),
    cardColor: navigationBackground,
    disabledColor: Colors.white10,
    fontFamily: GoogleFonts.nunito().fontFamily,
    radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(Colors.white), overlayColor: WidgetStateProperty.all(Colors.white)),
    appBarTheme: AppBarTheme(
      backgroundColor: appBackground,
      iconTheme: IconThemeData(color: textColorPrimary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: appBackground,
        systemNavigationBarColor: navigationBackground,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: colorPrimary,
      onPrimary: colorPrimary,
      secondary: colorPrimary,
    ),
    cardTheme: CardThemeData(color: navigationBackground),
    iconTheme: IconThemeData(color: textColorPrimary),
    textTheme: TextTheme(
      labelLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: textColorPrimary),
      titleSmall: TextStyle(color: textColorSecondary),
      bodySmall: TextStyle(color: textColorThird),
      titleLarge: TextStyle(color: Colors.white),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: navigationBackground,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      modalBackgroundColor: cardColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 14)),
    ),
  );
}