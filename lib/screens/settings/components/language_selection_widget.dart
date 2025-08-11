import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class LanguageSelectionWidget extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const LanguageSelectionWidget({Key? key, required this.onLanguageChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: LanguageDataModel.languageLocales().length,
      itemBuilder: (context, index) {
        LanguageDataModel data = localeLanguageList[index];
        Locale locale = LanguageDataModel.languageLocales()[index];
        bool isSelected = getStringAsync(SELECTED_LANGUAGE_CODE) ==
            data.languageCode.validate();

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.dividerColor),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedImageWidget(
                url: data.flag.validate(),
                height: 24,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              data.name.validate(),
              style: primaryTextStyle(),
            ),
            trailing: Radio<String>(
              value: data.languageCode.validate(),
              groupValue: getStringAsync(SELECTED_LANGUAGE_CODE),
              onChanged: (value) {
                onLanguageChange.call(locale);
              },
              activeColor: colorPrimary,
            ),
            onTap: () {
              onLanguageChange.call(locale);
            },
          ),
        );
      },
    );
  }
}
