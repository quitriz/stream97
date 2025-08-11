import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/live_tv/epg_components/epg_grid_component.dart';

class EpgProgramItemComponent extends StatelessWidget {
  final PositionedProgram pp;
  final int channelId;
  final void Function(String programId, int channelId)? onProgramTap;
  final void Function(int channelId)? onChannelTap;

  const EpgProgramItemComponent({
    Key? key,
    required this.pp,
    required this.channelId,
    this.onProgramTap,
    this.onChannelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final program = pp.program;
    final programWidth = pp.width;
    final isCurrent = epgStore.isProgramCurrent(program);

    const imageWidth = 40.0;
    const spacing = 4.0;
    const padding = 8.0;
    const minTextWidth = 80.0;

    final totalWidthWithImage = imageWidth + spacing + minTextWidth + padding;
    final showImage = programWidth >= totalWidthWithImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: programWidth,
        height: epgStore.channelRowHeight,
        margin: EdgeInsets.only(bottom: 10, right: 4, top: 6),
        decoration: BoxDecoration(
          gradient: isCurrent
              ? LinearGradient(
                  colors: [Colors.black, context.primaryColor.withValues(alpha: 0.5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isCurrent ? null : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () {
            if (!appStore.isLogging) {
              SignInScreen(redirectTo: () {}).launch(context);
            }
            if (isCurrent) {
              onProgramTap?.call(program.id.validate(), channelId);
              onChannelTap?.call(channelId);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                if (showImage) ...[
                  CachedImageWidget(width: imageWidth, height: 45, url: program.thumbnail.validate(), fit: BoxFit.cover).cornerRadiusWithClipRRect(4),
                  SizedBox(width: spacing)
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        program.title.validate(),
                        style: boldTextStyle(size: 14, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.height,
                      Text(
                        '${program.startTimeFormatted?.validate() ?? '--:--'} - '
                        '${program.endTimeFormatted?.validate() ?? '--:--'}',
                        style: secondaryTextStyle(size: 12, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
