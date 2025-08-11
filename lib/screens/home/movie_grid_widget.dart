import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';

// ignore: must_be_immutable
class MovieGridList extends StatefulWidget {
  List<CommonDataListModel> list = [];

  MovieGridList(this.list);

  @override
  State<MovieGridList> createState() => _MovieGridListState();
}

class _MovieGridListState extends State<MovieGridList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.list.map((e) {
        return CommonListItemComponent(data: e, isVerticalList: true);
      }).toList(),
    ).paddingAll(16);
  }
}
