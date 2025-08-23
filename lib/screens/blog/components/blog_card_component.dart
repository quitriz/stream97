import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/blog/wp_embedded_model.dart';
import 'package:streamit_flutter/models/blog/wp_post_response.dart';
import 'package:streamit_flutter/screens/blog/screens/blog_detail_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';


class BlogCardComponent extends StatefulWidget {
  final WpPostResponse data;

  BlogCardComponent({required this.data});

  @override
  State<BlogCardComponent> createState() => _BlogCardComponentState();
}

class _BlogCardComponentState extends State<BlogCardComponent> {
  List<String> tags = [];
  String category = '';

  @override
  void initState() {
    super.initState();

    getTags();
  }

  void getTags() {
    widget.data.embedded!.wpTerms!.forEach((element) {
      element.forEach((e) {
        WpTermsModel terms = WpTermsModel.fromJson(e);
        if (terms.taxonomy.validate() == 'category') {
          category = terms.name.validate();
        } else if (terms.taxonomy.validate() == 'post_tag') {
          tags.add(terms.name.validate());
        }
      });
    });

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.data.user_has_access.validate()) {
          BlogDetailScreen(blogId: widget.data.id.validate(), data: widget.data).launch(context);
        } else {
          if (appStore.isLogging && appStore.isMembershipEnabled) MembershipPlansScreen().launch(context);
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius()),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.data.embedded != null)
              RichText(
                text: TextSpan(
                  children: [
                    if (widget.data.embedded!.author!.first.name.validate().isNotEmpty)
                      TextSpan(
                        text: widget.data.embedded!.author!.first.name.validate() + '  |  ',
                        style: secondaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily),
                      ),
                    TextSpan(text: '${convertToAgo(widget.data.date.validate())}  |', style: secondaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily)),
                    TextSpan(text: '  $category', style: secondaryTextStyle(size: 14, fontFamily: GoogleFonts.nunito().fontFamily, color: context.primaryColor))
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            16.height,
            Text(parseHtmlString(widget.data.title!.rendered.validate()), style: boldTextStyle()),
            16.height,
            Text(parseHtmlString(widget.data.excerpt!.rendered.validate()), style: secondaryTextStyle(size: 16)),
            if (widget.data.embedded != null && widget.data.embedded!.featuredMedia != null)
              CachedImageWidget(
                url: widget.data.embedded!.featuredMedia!.first.source_url.validate(),
                height: 150,
                width: context.width(),
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(defaultRadius),
            if (tags.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${language.tags}: ', style: boldTextStyle(size: 14)),
                  Wrap(
                    children: tags.map((e) {
                      return Text('$e, ', style: secondaryTextStyle());
                    }).toList(),
                  ).expand(),
                ],
              ).paddingTop(16),
          ],
        ),
      ),
    );
  }
}