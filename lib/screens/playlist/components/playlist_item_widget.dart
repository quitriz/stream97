import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/playlist/screens/playlist_medialist_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class PlayListItemWidget extends StatefulWidget {
  final String playlistType;
  final VoidCallback? onPlaylistDelete;

  const PlayListItemWidget(
      {Key? key, required this.playlistType, this.onPlaylistDelete})
      : super(key: key);

  @override
  State<PlayListItemWidget> createState() => PlayListItemWidgetState();
}

class PlayListItemWidgetState extends State<PlayListItemWidget> {
  final _form = GlobalKey<FormState>();
  TextEditingController _playlistTitleController = TextEditingController();

  String noDataTitle = '';
  Future<List<PlaylistModel>>? future;

  @override
  void initState() {
    super.initState();

    if (widget.playlistType == playlistMovie) {
      noDataTitle = language.movies;
    } else if (widget.playlistType == playlistEpisodes) {
      noDataTitle = language.episodes;
    } else {
      noDataTitle = language.videos;
    }
    future = getPlayListByType(type: widget.playlistType);
    setState(() {});
  }

  onCreategrpup(String playlistType) async {
    future = getPlayListByType(type: playlistType);
    setState(() {});
  }

  Future<void> refreshPlaylist() async {
    // Reload playlist or refresh state logic here
    setState(() {});
  }

  void removePlaylist(BuildContext context, {required int playlistId}) async {
    Map req = {"playlist_id": playlistId};
    appStore.setLoading(true);
    await deletePlaylist(request: req, type: widget.playlistType).then((value) {
      widget.onPlaylistDelete?.call();
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(language.somethingWentWrong);
      log("===>>>>>Delete Playlist Error : ${e.toString()}");
    });
  }

  void editPlaylist(BuildContext context,
      {required int playlistId, required String postType}) async {
    Map req = {
      "id": playlistId,
      "title": _playlistTitleController.text.trim(),
    };
    hideKeyboard(context);
    appStore.setLoading(true);
    await createOrEditPlaylist(request: req, type: widget.playlistType)
        .then((value) {
      widget.onPlaylistDelete?.call();
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(language.somethingWentWrong);
      log("===>>>>>Delete Playlist Error : ${e.toString()}");
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlaylistModel>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.hasData) {
          if (snap.data!.validate().isNotEmpty) {
            return SingleChildScrollView(
              child: AnimatedWrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 12,
                runSpacing: 12,
                itemCount: snap.data!.length,
                itemBuilder: (p0, index) {
                  PlaylistModel _playlistItem = snap.data.validate()[index];
                  return playlistItemComponent(playlistItem: _playlistItem)
                      .paddingSymmetric(horizontal: 8);
                },
              ),
            );
            //  AnimatedListView(
            //   itemCount: snap.data!.length,
            //   padding: EdgeInsets.all(8),
            //   itemBuilder: (ctxx, index) {
            //     PlaylistModel _playlistItem = snap.data.validate()[index];

            //     return Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SplashWidget(
            //         borderRadius: 8,
            //         backgroundColor: context.scaffoldBackgroundColor,
            //         hasShadow: true,
            //         padding: EdgeInsets.only(left: 16, right: 0),
            //         onTap: () {
            //           PlaylistMediaScreen(
            //             playlistTitle: _playlistItem.playlistName,
            //             playlistId: _playlistItem.playlistId,
            //             playlistType: _playlistItem.postType,
            //           ).launch(context);
            //         },
            //         child: Row(
            //           children: [
            //             Image.asset(
            //               ic_playlist,
            //               height: 24,
            //               width: 24,
            //               color: colorPrimary,
            //             ),
            //             16.width,
            //             Text(_playlistItem.playlistName.validate(), style: primaryTextStyle(weight: FontWeight.w100)).expand(),
            //             IconButton(
            //               onPressed: () {
            //                 HapticFeedback.lightImpact();
            //                 showModalBottomSheet(
            //                   context: context,
            //                   isScrollControlled: true,
            //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //                   backgroundColor: Colors.transparent,
            //                   builder: (bottomSheetContext) {
            //                     return Container(
            //                       margin: EdgeInsets.all(8),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xFF202020),
            //                         borderRadius: BorderRadius.circular(16),
            //                       ),
            //                       child: AnimatedPadding(
            //                         duration: Duration(milliseconds: 350),
            //                         padding: EdgeInsets.all(16),
            //                         child: Column(
            //                           mainAxisSize: MainAxisSize.min,
            //                           crossAxisAlignment: CrossAxisAlignment.start,
            //                           children: [
            //                             Align(
            //                               alignment: Alignment.center,
            //                               child: Container(
            //                                 width: 30,
            //                                 height: 3,
            //                                 decoration: BoxDecoration(
            //                                   color: Color(0xFFA8A8A8),
            //                                   borderRadius: BorderRadius.circular(16),
            //                                 ),
            //                               ),
            //                             ),
            //                             24.height,
            //                             Row(
            //                               crossAxisAlignment: CrossAxisAlignment.start,
            //                               children: [
            //                                 Image.asset(
            //                                   ic_playlist,
            //                                   height: 32,
            //                                   width: 32,
            //                                   color: colorPrimary,
            //                                 ),
            //                                 16.width,
            //                                 Column(
            //                                   mainAxisSize: MainAxisSize.min,
            //                                   crossAxisAlignment: CrossAxisAlignment.start,
            //                                   children: [
            //                                     Text(
            //                                       _playlistItem.postType,
            //                                       style: primaryTextStyle(size: 22),
            //                                       maxLines: 1,
            //                                       overflow: TextOverflow.ellipsis,
            //                                     ),
            //                                     8.height,
            //                                     // Text(
            //                                     //   DateFormat(dateFormatPmp).format(DateTime.parse(_playlistItem.postDate)),
            //                                     //   style: secondaryTextStyle(size: 16),
            //                                     //   maxLines: 1,
            //                                     //   overflow: TextOverflow.ellipsis,
            //                                     // ),
            //                                   ],
            //                                 )
            //                               ],
            //                             ),
            //                             16.height,
            //                             Divider(color: Color(0xFFA8A8A8)),
            //                             16.height,
            //                             InkWell(
            //                               onTap: () {
            //                                 finish(bottomSheetContext);
            //                                 _playlistTitleController.text = _playlistItem.postType;
            //                                 showDialog(
            //                                   context: context,
            //                                   builder: (dialogContext) {
            //                                     return Dialog(
            //                                       child: Form(
            //                                         key: _form,
            //                                         child: Column(
            //                                           crossAxisAlignment: CrossAxisAlignment.start,
            //                                           mainAxisSize: MainAxisSize.min,
            //                                           children: [
            //                                             Text("${language.edit} ${_playlistItem.postType}", style: primaryTextStyle(size: 22)),
            //                                             16.height,
            //                                             AppTextField(
            //                                               controller: _playlistTitleController,
            //                                               textFieldType: TextFieldType.NAME,
            //                                               decoration: InputDecoration(
            //                                                 hintText: "E.g. Coffee Break",
            //                                                 labelText: language.playlistTitle,
            //                                                 labelStyle: primaryTextStyle(color: Color(0xFFA8A8A8)),
            //                                                 hintStyle: primaryTextStyle(color: Color(0xFF484848)),
            //                                                 focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
            //                                                 enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
            //                                                 errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
            //                                                 border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
            //                                               ),
            //                                               validator: (val) {
            //                                                 if (val.validate().isEmpty) return language.thisFieldIsRequired;
            //                                                 return null;
            //                                               },
            //                                             ),
            //                                             24.height,
            //                                             Observer(
            //                                               builder: (_) {
            //                                                 return appStore.isLoading
            //                                                     ? CircularProgressIndicator(strokeWidth: 2).center()
            //                                                     : Align(
            //                                                         alignment: Alignment.centerRight,
            //                                                         child: Row(
            //                                                           mainAxisSize: MainAxisSize.min,
            //                                                           children: [
            //                                                             TextButton(
            //                                                               style: ButtonStyle(
            //                                                                 shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            //                                                               ),
            //                                                               onPressed: () {
            //                                                                 finish(dialogContext);
            //                                                               },
            //                                                               child: Text(language.cancel, style: primaryTextStyle()),
            //                                                             ),
            //                                                             16.width,
            //                                                             TextButton(
            //                                                               style: ButtonStyle(
            //                                                                 backgroundColor: WidgetStateProperty.all(colorPrimary),
            //                                                                 shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            //                                                               ),
            //                                                               onPressed: () {
            //                                                                 editPlaylist(dialogContext, playlistId: _playlistItem.playlistId, postType: _playlistItem.postType);
            //                                                               },
            //                                                               child: Text(language.edit, style: primaryTextStyle(color: Colors.white)),
            //                                                             )
            //                                                           ],
            //                                                         ),
            //                                                       );
            //                                               },
            //                                             ),
            //                                           ],
            //                                         ).paddingAll(16),
            //                                       ),
            //                                     );
            //                                   },
            //                                 );
            //                               },
            //                               child: Row(
            //                                 children: [
            //                                   Icon(Icons.edit_rounded, color: Color(0xFFA8A8A8)),
            //                                   16.width,
            //                                   Text(
            //                                     language.editPlaylist,
            //                                     style: primaryTextStyle(size: 18, color: Color(0xFFA8A8A8)),
            //                                     overflow: TextOverflow.ellipsis,
            //                                     maxLines: 1,
            //                                   ).expand(),
            //                                 ],
            //                               ).paddingAll(8),
            //                             ),
            //                             16.height,
            //                             InkWell(
            //                               onTap: () {
            //                                 finish(bottomSheetContext);
            //                                 showDialog(
            //                                   context: context,
            //                                   builder: (dialogContext) {
            //                                     return Dialog(
            //                                       child: Column(
            //                                         crossAxisAlignment: CrossAxisAlignment.start,
            //                                         mainAxisSize: MainAxisSize.min,
            //                                         children: [
            //                                           Text("${language.delete} ${_playlistItem.postType}", style: primaryTextStyle(size: 22)),
            //                                           16.height,
            //                                           Text("${language.areYouSureYouWantToDelete} ${_playlistItem.postType}?", style: primaryTextStyle()),
            //                                           24.height,
            //                                           Observer(
            //                                             builder: (_) {
            //                                               return appStore.isLoading
            //                                                   ? CircularProgressIndicator(strokeWidth: 2).center()
            //                                                   : Align(
            //                                                       alignment: Alignment.centerRight,
            //                                                       child: Row(
            //                                                         mainAxisSize: MainAxisSize.min,
            //                                                         children: [
            //                                                           TextButton(
            //                                                             style: ButtonStyle(
            //                                                               shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            //                                                             ),
            //                                                             onPressed: () {
            //                                                               finish(dialogContext);
            //                                                             },
            //                                                             child: Text(language.cancel, style: primaryTextStyle()),
            //                                                           ),
            //                                                           16.width,
            //                                                           TextButton(
            //                                                             style: ButtonStyle(
            //                                                               backgroundColor: WidgetStateProperty.all(colorPrimary),
            //                                                               shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            //                                                             ),
            //                                                             onPressed: () {
            //                                                               removePlaylist(dialogContext, playlistId: _playlistItem.playlistId);
            //                                                             },
            //                                                             child: Text(language.delete, style: primaryTextStyle(color: Colors.white)),
            //                                                           )
            //                                                         ],
            //                                                       ),
            //                                                     );
            //                                             },
            //                                           ),
            //                                         ],
            //                                       ).paddingAll(16),
            //                                     );
            //                                   },
            //                                 );
            //                               },
            //                               child: Row(
            //                                 children: [
            //                                   Icon(Icons.close_rounded, color: Color(0xFFA8A8A8)),
            //                                   16.width,
            //                                   Text(
            //                                     language.deletePlaylist,
            //                                     style: primaryTextStyle(size: 18, color: Color(0xFFA8A8A8)),
            //                                     overflow: TextOverflow.ellipsis,
            //                                     maxLines: 1,
            //                                   ).expand(),
            //                                 ],
            //                               ).paddingAll(8),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 );
            //               },
            //               icon: Icon(Icons.more_vert, color: context.iconColor),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // );
          } else {
            return NoDataWidget(
              imageWidget: noDataImage(),
              title: '${language.noPlaylistsFoundFor} $noDataTitle',
              subTitle: '${language.createPlaylistAndAdd} $noDataTitle',
            );
          }
        } else if (snap.hasError) {
          return NoDataWidget(
            imageWidget: noDataImage(),
            title: language.somethingWentWrong,
          ).center();
        }
        return LoaderWidget();
      },
    );
  }

  Widget playlistItemComponent({required PlaylistModel playlistItem}) {
    return InkWell(
      onTap: () {
        PlaylistMediaScreen(
          playlistTitle: playlistItem.playlistName,
          playlistId: playlistItem.playlistId,
          playlistType: playlistItem.postType,
        ).launch(context).then((v) {
          future = getPlayListByType(type: widget.playlistType);
          setState(() {});
        });
      },
      child: Container(
        width: context.width() / 2 - 24,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedImageWidget(
                url: playlistItem.image.validate(),
                height: 120,
                width: context.width() / 2 - 24,
                fit: BoxFit.cover,
                radius: 8),
            8.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Marquee(
                            child: Text(playlistItem.playlistName.validate(),
                                style: boldTextStyle(size: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis))
                        .paddingSymmetric(horizontal: 8),
                    Text('${playlistItem.dataCount}',
                            style: secondaryTextStyle(size: 14))
                        .paddingSymmetric(horizontal: 8),
                  ],
                ).expand(),
                PopupMenuButton(
                  color: search_edittext_color,
                  onSelected: (value) {
                    if (value == 1) {
                      deletePlayListDialog(playlist: playlistItem);
                    } else {
                      editPlaylistDialog(playlistItem: playlistItem);
                    }
                  },
                  itemBuilder: (ctx) => [
                    buildPopupMenuItem(language.edit, 0),
                    buildPopupMenuItem(language.delete, 1),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem buildPopupMenuItem(String title, index) {
    return PopupMenuItem(
      value: index,
      child: Text(
        title,
        style: boldTextStyle(),
      ),
    );
  }

  void deletePlayListDialog({required PlaylistModel playlist}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: search_edittext_color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "${language.delete} ${playlist.label.capitalizeFirstLetter()} ${language.playlist}",
                  style: primaryTextStyle(size: 22)),
              16.height,
              Text(
                  "${language.areYouSureYouWantToDelete} ${playlist.playlistName} ?",
                  style: primaryTextStyle()),
              24.height,
              Observer(
                builder: (_) {
                  return appStore.isLoading
                      ? CircularProgressIndicator(strokeWidth: 2).center()
                      : Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24))),
                                ),
                                onPressed: () {
                                  finish(dialogContext);
                                },
                                child: Text(language.cancel,
                                    style: primaryTextStyle()),
                              ),
                              16.width,
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(colorPrimary),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24))),
                                ),
                                onPressed: () {
                                  removePlaylist(dialogContext,
                                      playlistId: playlist.playlistId);
                                },
                                child: Text(language.delete,
                                    style:
                                        primaryTextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        );
                },
              ),
            ],
          ).paddingAll(16),
        );
      },
    );
  }

  void editPlaylistDialog({required PlaylistModel playlistItem}) {
    _playlistTitleController.text = playlistItem.playlistName;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: search_edittext_color,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${language.edit} ${playlistItem.playlistName}",
                    style: primaryTextStyle(size: 22)),
                16.height,
                AppTextField(
                  controller: _playlistTitleController,
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    hintText: "E.g. Coffee Break",
                    labelText: language.playlistTitle,
                    labelStyle: primaryTextStyle(color: Color(0xFFA8A8A8)),
                    hintStyle: primaryTextStyle(color: Color(0xFF484848)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF696969))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF696969))),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF696969))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF696969))),
                  ),
                  validator: (val) {
                    if (val.validate().isEmpty)
                      return language.thisFieldIsRequired;
                    return null;
                  },
                ),
                24.height,
                Observer(
                  builder: (_) {
                    return appStore.isLoading
                        ? CircularProgressIndicator(strokeWidth: 2).center()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24))),
                                  ),
                                  onPressed: () {
                                    finish(dialogContext);
                                  },
                                  child: Text(language.cancel,
                                      style: primaryTextStyle()),
                                ),
                                16.width,
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(colorPrimary),
                                    shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24))),
                                  ),
                                  onPressed: () {
                                    editPlaylist(dialogContext,
                                        playlistId: playlistItem.playlistId,
                                        postType: playlistItem.postType);
                                  },
                                  child: Text(language.update,
                                      style: primaryTextStyle(
                                          color: Colors.white)),
                                )
                              ],
                            ),
                          );
                  },
                ),
              ],
            ).paddingAll(16),
          ),
        );
      },
    );
  }
}
