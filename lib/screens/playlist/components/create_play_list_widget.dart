import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/common/data_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class CreatePlayListWidget extends StatefulWidget {
  final VoidCallback? onPlaylistCreated;
  final String? playlistType;

  const CreatePlayListWidget({this.onPlaylistCreated, this.playlistType});

  @override
  State<CreatePlayListWidget> createState() => _CreatePlayListWidgetState();
}

class _CreatePlayListWidgetState extends State<CreatePlayListWidget> {
  TextEditingController _playlistTitleController = TextEditingController();
  final _playlistFromKey = GlobalKey<FormState>();
  List<DataModel> _playListTypeList = [];
  late DataModel _playlistType;

  @override
  void initState() {
    _playListTypeList.add(DataModel(title: language.movies, data: playlistMovie));
    _playListTypeList.add(DataModel(title: language.episodes, data: playlistEpisodes));
    _playListTypeList.add(DataModel(title: language.videos, data: playlistVideo));

    if (widget.playlistType != null) {
      _playlistType = _playListTypeList.firstWhere((element) => element.data == widget.playlistType);
    } else {
      _playlistType = _playListTypeList.first;
    }
    super.initState();
  }

  void createPlayList(BuildContext context, {required String playlistName, required String playlistType}) async {
    Map req = {
      "title": playlistName,
    };
    appStore.setLoading(true);
    await createOrEditPlaylist(request: req, type: playlistType).then((value) {
      toast(value.message);
      finish(context);
      appStore.setLoading(false);
      widget.onPlaylistCreated?.call();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(language.somethingWentWrong);
      log("====>>>>Create Playlist Error : ${e.toString()}");
      finish(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF202020),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedPadding(
          duration: Duration(milliseconds: 350),
          padding: EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _playlistFromKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFFA8A8A8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                16.height,
                TextFormField(
                  controller: _playlistTitleController,
                  keyboardType: TextInputType.text,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    hintText: "E.g. Coffee Break",
                    labelText: language.playlistTitle,
                    labelStyle: primaryTextStyle(color: Color(0xFFA8A8A8)),
                    hintStyle: primaryTextStyle(color: Color(0xFF484848)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF696969))),
                  ),
                  validator: (value) {
                    if (value!.isEmpty)
                      return language.thisFieldIsRequired;
                    else if (value.startsWith(" ")) return language.enterValidPlaylistName;
                    return null;
                  },
                ),
                16.height,
                Text(
                  language.selectWhereYouWant,
                  style: primaryTextStyle(color: Color(0xFFA8A8A8)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                16.height,
                Container(
                  decoration: boxDecorationWithRoundedCorners(backgroundColor: Color(0xFF303030)),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DataModel>(
                      isExpanded: true,
                      dropdownColor: Color(0xFF303030),
                      borderRadius: BorderRadius.circular(defaultRadius),
                      items: _playListTypeList.map((value) {
                        return DropdownMenuItem(
                          child: Text(value.title, style: primaryTextStyle()),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (DataModel? type) {
                        setState(() {
                          _playlistType = type!;
                        });
                      },
                      value: _playlistType,
                    ),
                  ),
                ),
                24.height,
                Observer(
                  builder: (_) {
                    return appStore.isLoading
                        ? CircularProgressIndicator(strokeWidth: 2).center()
                        : AppButton(
                            width: context.width(),
                            onTap: () async {
                              if (_playlistFromKey.currentState!.validate()) {
                                _playlistFromKey.currentState!.save();
                                hideKeyboard(context);
                                createPlayList(context, playlistName: _playlistTitleController.text.trim(), playlistType: _playlistType.data);
                              }
                            },
                            color: colorPrimary,
                            child: Text(language.createList, style: boldTextStyle(color: Colors.white)),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
