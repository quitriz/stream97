import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/local/base_language.dart';
import 'package:streamit_flutter/local/language_vi.dart';
import 'package:streamit_flutter/local/language_en.dart';
import 'package:streamit_flutter/local/language_fr.dart';
import 'package:streamit_flutter/local/language_hi.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'vi':
        return LanguageVi();
      case 'hi':
        return LanguageHi();
      case 'fr':
        return LanguageFr();

      default:
        return LanguageVi();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
