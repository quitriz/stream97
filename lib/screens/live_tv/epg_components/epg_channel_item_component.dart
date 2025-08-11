import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/live_tv/epg_data_model.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class EPGChannelItemComponent extends StatelessWidget {
  final EpgChannel channel;
  final bool isSelected;
  final Function(int channelId)? onChannelTap;

  const EPGChannelItemComponent({Key? key, required this.channel, required this.isSelected, this.onChannelTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: epgStore.channelRowHeight,
      width: epgStore.channelColumnWidth - 10,
      margin: EdgeInsets.only(bottom: 10, right: 4, top: 6),
      decoration: BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => onChannelTap?.call(channel.id.validate()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedImageWidget(
              width: 55,
              height: 40,
              url: channel.thumbnailImage.validate().isNotEmpty ? channel.thumbnailImage.validate() : default_image,
              fit: BoxFit.contain,
            ).cornerRadiusWithClipRRect(4),
            4.height,
            Text(
              channel.title.validate(),
              style: boldTextStyle(size: 12, color: isSelected ? context.primaryColor : Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
