import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart' show RecentSearchListModel;
import 'package:streamit_flutter/network/rest_apis.dart';

class RecentSearchList extends StatefulWidget {
  List<RecentSearchListModel> list = [];
  final Function(String) onItemTap;
  final Function(int) onRemoveRecent;

  RecentSearchList(this.list, {required this.onItemTap, required this.onRemoveRecent});

  @override
  State<RecentSearchList> createState() => _RecentSearchListState();
}

class _RecentSearchListState extends State<RecentSearchList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                    child: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                )),
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.list[index].term.toString(),
                    style: secondaryTextStyle(size: 16),
                  ).onTap(() {
                    widget.onItemTap(widget.list[index].term.toString());
                  }),
                ),
                Expanded(
                    child: IconButton(
                        onPressed: () {
                          removeRecent(widget.list[index].id!);
                          widget.list.removeAt(index);
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey,
                        ))),
              ],
            )
          );
        });
  }
}
