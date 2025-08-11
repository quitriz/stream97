import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/blog/wp_comments_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/blog/components/edit_blog_comment_component.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class BlogCommentComponent extends StatelessWidget {
  final WpCommentModel comment;
  final VoidCallback onDelete;
  final Function(WpCommentModel) onUpdate;

  BlogCommentComponent({required this.comment, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: search_edittext_color,borderRadius: radius()),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImageWidget(
                url: comment.author_avatar_urls!.ninetySix.validate(),
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(25),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.author_name.validate(), style: primaryTextStyle()),
                  4.height,
                  Text(convertToAgo(comment.date.validate()), style: secondaryTextStyle(size: 12)),
                ],
              ).expand(),
              if (comment.author == appStore.userId)
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          builder: (p0) {
                            return EditBlogCommentComponent(
                              id: comment.id.validate(),
                              comment: parseHtmlString(comment.content!.rendered.validate()),
                              onUpdate: (value) {
                                onUpdate.call(value);
                              },
                            );
                          },
                        );
                      },
                      child: Icon(Icons.edit, color: context.primaryColor, size: 18),
                    ),
                    8.width,
                    InkWell(
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          onAccept: (c) {
                            onDelete.call();
                            deleteBlogComment(commentId: comment.id.validate()).then((value) {
                              toast("${value.message}");
                              //
                            }).catchError((e) {
                              toast(e.toString(), print: true);
                            });
                          },
                          dialogType: DialogType.DELETE,
                          title: language!.deleteCommentConfirmation,
                          positiveText: language!.delete,
                        );
                      },
                      child: Icon(Icons.delete_outline,color: Colors.red, size: 18),
                      //child: Image.asset(ic_delete, color: Colors.red, height: 18, width: 18, fit: BoxFit.cover),
                    ),
                  ],
                ),
            ],
          ),
          8.height,
          Text(parseHtmlString(comment.content!.rendered.validate()), style: secondaryTextStyle()).paddingSymmetric(horizontal: 16)
        ],
      ),
    );
  }
}
