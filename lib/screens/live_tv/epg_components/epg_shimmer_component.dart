import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/main.dart';

class EPGShimmerComponent extends StatelessWidget {
  const EPGShimmerComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height() * 0.6,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[700]!,
        child: AbsorbPointer(
          child: Column(
            children: [
              _buildHeaderShimmer(context),
              Expanded(child: _buildGridShimmer(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(BuildContext context) {
    final timelineHeight = epgStore.timelineHeight;
    final slotCount = epgStore.timeSlots.length;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: epgStore.channelColumnWidth - 10,
            height: timelineHeight + 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),topLeft: Radius.circular(8)),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: timelineHeight + 40,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Row(
                          children: List.generate(
                            slotCount,
                            (_) => Container(
                              width: epgStore.timeSlotWidth,
                              height: timelineHeight,
                              margin: const EdgeInsets.only(right: 0.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        2.height,
                        Row(
                          children: List.generate(
                            slotCount,
                                (_) => Container(
                              width: epgStore.timeSlotWidth,
                              height: timelineHeight,
                              margin: const EdgeInsets.only(right: 0.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ShimmerTimeLineIndicator(
                    height: timelineHeight,
                    width: slotCount * epgStore.timeSlotWidth,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridShimmer(BuildContext context) {
    final slotCount = epgStore.timeSlots.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channels Column
          SizedBox(
            width: epgStore.channelColumnWidth - 10,
            child: ListView.builder(
              itemCount: 10,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) {
                return Container(
                  height: epgStore.channelRowHeight,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: radius(8),
                  ),
                );
              },
            ),
          ),
          8.width,
          // Programs
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) {
                return Container(
                  height: epgStore.channelRowHeight,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            slotCount,
                            (_) => Container(
                              width: epgStore.timeSlotWidth,
                              height: epgStore.channelRowHeight,
                              margin: const EdgeInsets.only(right: 0.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: radius(8),
                              ),
                            ).paddingRight(2),
                          ),
                        ),
                      ),
                      _ShimmerTimeLineIndicator(
                        height: epgStore.channelRowHeight,
                        width: slotCount * epgStore.timeSlotWidth,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTimeLineIndicator extends StatelessWidget {
  final double height;
  final double width;
  const _ShimmerTimeLineIndicator({required this.height, required this.width});

  double _getCurrentTimeOffset() {
    if (epgStore.selectedDateIndex != 1) return -1;
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    return minutes * epgStore.pixelsPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    final offset = _getCurrentTimeOffset();
    if (offset < 0 || offset > width) return SizedBox.shrink();
    return Positioned(
      left: offset,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        height: height,
        color: Colors.grey[400], // shimmer color for the indicator
      ),
    );
  }
}
