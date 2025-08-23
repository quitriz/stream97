import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/screens/cast/cast_components.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/models/movie_episode/cast_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../../main.dart';

class CastDetailScreen extends StatefulWidget {
  static String tag = '/CastDetailScreen';
  final String? castId;

  CastDetailScreen({this.castId});

  @override
  CastDetailScreenState createState() => CastDetailScreenState();
}

class CastDetailScreenState extends State<CastDetailScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  openSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return CastBottomSheet(castId: widget.castId);
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CastModel>(
        future: getCastDetails(widget.castId!),
        builder: (context, snap) {
          if (snap.hasData) {
            CastModel cast = snap.data!;

            if (cast.data != null) {
              return SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BackButton(),
                    //region imageAndName
                    Container(
                      width: context.width(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedImageWidget(
                            url: cast.data!.image.validate().isEmpty ? default_image : cast.data!.image.validate(),
                            fit: BoxFit.cover,
                            width: context.width() * 0.2,
                            height: 200,
                          ).cornerRadiusWithClipRRect(radius_container).paddingSymmetric(horizontal: 16, vertical: 8).expand(flex: 3),
                          Text(cast.data!.title!.validate(), style: boldTextStyle(size: 22, color: Colors.white)).paddingAll(8).expand(flex: 2),
                        ],
                      ),
                    ),
                    16.height,
                    //endregion

                    Divider(thickness: 0.1, color: Colors.grey.shade500, height: 0),

                    //region personalDetail and description
                   
                    Text(
                      language.description,
                      style: primaryTextStyle(size: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).paddingAll(16),
                    ReadMoreText(
                      cast.data!.description.validate(),
                      style: primaryTextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                      trimLines: 3,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' ...${language.viewMore}',
                      trimExpandedText: '  ${language.viewLess}',
                    ).paddingSymmetric(horizontal: 16),

                    Text(
                      language.personalInfo,
                      style: primaryTextStyle(size: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).paddingAll(16),
                    Row(
                      children: [
                        PersonalInfoWidget(title: cast.data!.category.validate(), subTitle: language.knownFor).expand(),
                        Container(height: 50, width: 0.2, color: Colors.grey.shade500),
                        PersonalInfoWidget(title: cast.data!.credits.toString().validate(), subTitle: language.knownCredits).expand(),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        PersonalInfoWidget(title: cast.data!.placeOfBirth.validate(), subTitle: language.placeOfBirth).center().expand(),
                        Container(height: 50, width: 0.2, color: Colors.grey.shade500),
                        PersonalInfoWidget(title: cast.data!.alsoKnownAs.validate(), subTitle: language.alsoKnownAs).expand(),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        PersonalInfoWidget(title: '${cast.data!.birthday.validate(value: '-')}', subTitle: language.birthday).expand(),
                        Container(height: 50, width: 0.2, color: Colors.grey.shade500),
                        PersonalInfoWidget(title: '${cast.data!.deathDay.validate(value: '-')}', subTitle: language.deathDay).expand(),
                      ],
                    ),
                    16.height,
                    //endregion

                    Divider(thickness: 0.1, color: Colors.grey.shade500),

                    //region mostViewList
                    Text(
                      language.mostViewed,
                      style: primaryTextStyle(size: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).paddingAll(16).visible(cast.mostViewedContent!.isNotEmpty),
                    HorizontalList(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: cast.mostViewedContent!.length,
                      itemBuilder: (context, index) {
                        return CommonListItemComponent(data: cast.mostViewedContent![index]);
                      },
                    ),
                    //endregion
                    Divider(thickness: 0.1, color: Colors.grey.shade500),
                    AppButton(
                      width: context.width(),
                      color: colorPrimary,
                      onTap: () {
                        openSheet(context);
                      },
                      child: Text(
                        '${cast.data!.title.validate()}\'${language.sActing}',
                        style: boldTextStyle(color: textColorPrimary),
                      ),
                    ).paddingAll(8),
                  ],
                ),
              );
            } else {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: language.detailsAreNotAvailable,
                subTitle: language.theContentHasNot,
              ).center();
            }
          }
          return snapWidgetHelper(
            snap,
            loadingWidget: LoaderWidget(),
            errorWidget: NoDataWidget(
              imageWidget: noDataImage(),
              title: language.somethingWentWrong,
            ).center(),
          ).center();
        },
      ),
    );
  }
}
