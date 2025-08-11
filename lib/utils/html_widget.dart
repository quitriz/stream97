import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:streamit_flutter/utils/common.dart';

const ARTICLE_LINE_HEIGHT = 1.5;

class HtmlWidget extends StatelessWidget {
  final String? postContent;
  final Color? color;
  final double fontSize;
  final int? blogId;

  HtmlWidget({this.postContent, this.color, this.fontSize = 14.0, this.blogId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (postContent.validate().contains('youtube_url'))
          YoutubeComponent(
            postContent: postContent.validate(),
            key: ValueKey(blogId),
          ),
        Html(
          data: postContent.validate(),
          onLinkTap: (s, _, __) {
            appLaunchUrl(s.validate(), forceWebView: true);
          },
          onAnchorTap: (s, _, __) async {
            appLaunchUrl(s.validate(), forceWebView: true);
          },
          style: {
            "table": Style(backgroundColor: color ?? transparentColor, lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            "tr": Style(border: Border(bottom: BorderSide(color: Colors.black45.withValues(alpha:0.5))), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            "th": Style(padding: HtmlPaddings.zero, backgroundColor: Colors.black45.withValues(alpha:0.5), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT)),
            "td": Style(padding: HtmlPaddings.zero, alignment: Alignment.center, lineHeight: LineHeight(ARTICLE_LINE_HEIGHT)),
            'embed': Style(
                color: color ?? transparentColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: FontSize(fontSize),
                lineHeight: LineHeight(ARTICLE_LINE_HEIGHT),
                padding: HtmlPaddings.zero),
            'strong': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'a': Style(
              color: context.primaryColor,
              // color: color ?? context.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: FontSize(fontSize),
              lineHeight: LineHeight(ARTICLE_LINE_HEIGHT),
              padding: HtmlPaddings.zero,
              textDecoration: TextDecoration.none,
            ),
            'div': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'figure': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), padding: HtmlPaddings.zero, margin: Margins.zero, lineHeight: LineHeight(ARTICLE_LINE_HEIGHT)),
            'h1': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'h2': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'h3': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'h4': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'h5': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'h6': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'p': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), textAlign: TextAlign.justify, lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'ol': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'ul': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'strike': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'u': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'b': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'i': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'hr': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'header': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'code': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'data': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'body': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'big': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), lineHeight: LineHeight(ARTICLE_LINE_HEIGHT), padding: HtmlPaddings.zero),
            'audio': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(fontSize), padding: HtmlPaddings.zero),
            'img': Style(width: Width(context.width()), padding: HtmlPaddings.only(bottom: 8), fontSize: FontSize(fontSize)),
            'li': Style(
              color: color ?? textPrimaryColorGlobal,
              fontSize: FontSize(fontSize),
              listStyleType: ListStyleType.disc,
              listStylePosition: ListStylePosition.outside,
            ),
          },
          extensions: [
            TagExtension(
              tagsToExtend: {'embed'},
              builder: (extensionContext) {
                var videoLink = extensionContext.parser.htmlData.text.splitBetween('<embed>', '</embed');

                if (videoLink.contains('yout')) {
                  return YoutubeComponent(
                    postContent: extensionContext.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').toYouTubeId(),
                    key: ValueKey(blogId),
                  );
                } else if (videoLink.contains('vimeo')) {
                  return Offstage();
                  // return VimeoEmbedWidget(videoLink.replaceAll('<br>', ''));
                } else {
                  return Offstage();
                }
              },
            ),
            TagExtension(
              tagsToExtend: {'figure'},
              builder: (extensionContext) {
                if (extensionContext.innerHtml.contains('yout')) {


                  return YoutubeComponent(
                    postContent: extensionContext.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').toYouTubeId(),
                    key: ValueKey(blogId),
                  );
                } else if (extensionContext.innerHtml.contains('vimeo')) {
                  return Offstage();

                  // return VimeoEmbedWidget(extensionContext.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').splitAfter('com/'));
                } else if (extensionContext.innerHtml.validate().contains('img')) {
                  String img = '';

                  img = extensionContext.innerHtml.splitAfter('<a href="').splitBefore('"><img loading');
                  if (img.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: img,
                      width: context.width(),
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(defaultRadius).onTap(() {});
                  } else {
                    return Offstage();
                  }
                }
                return Offstage();
              },
            ),
            TagExtension(
              tagsToExtend: {'img'},
              builder: (extensionContext) {
                String img = '';
                if (extensionContext.attributes.containsKey('src')) {
                  img = extensionContext.attributes['src'].validate();
                } else if (extensionContext.attributes.containsKey('data-src')) {
                  img = extensionContext.attributes['data-src'].validate();
                }
                if (img.isNotEmpty) {
                  return CachedNetworkImage(
                    imageUrl: img,
                    width: context.width(),
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(defaultRadius).onTap(() {
                    //OpenPhotoViewer(photoImage: img).launch(context);
                  });
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class YoutubeComponent extends StatefulWidget {
  final String? postContent;
  final Key key;

  const YoutubeComponent({this.postContent, required this.key});

  @override
  State<YoutubeComponent> createState() => _YoutubeComponentState();
}

class _YoutubeComponentState extends State<YoutubeComponent> {
  String videoId = '';

  @override
  void initState() {
    super.initState();

    extractDivAttributes(widget.postContent.validate());
  }

  void extractDivAttributes(String htmlText) {
    RegExp regExp = RegExp(r'"youtube_url":"([^"]+)"');
    Match? match = regExp.firstMatch(htmlText);

    if (match != null) {
      String youtubeURL = match.group(1)!;
      youtubeURL = json.decode('"$youtubeURL"');
      videoId = youtubeURL.toYouTubeId();
    } else {
      print('YouTube URL not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage();

    //return YouTubeEmbedWidget(videoId, key: widget.key);
  }
}
