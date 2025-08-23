import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';

class EPGTimelineHeaderWidget extends StatelessWidget {
  final ScrollController timelineScrollController;
  final Function(int index) onDateSelected;

  const EPGTimelineHeaderWidget({
    Key? key,
    required this.timelineScrollController,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        color: context.scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: epgStore.channelColumnWidth - 10,
              height: epgStore.timelineHeight + 40,
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    right: BorderSide(color: Colors.grey[800]!, width: 1),
                    bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                  ),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              child: Center(
                child: Text(
                  '${language.dayTime} / \n ${language.channels}',
                  style: boldTextStyle(size: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ).paddingOnly(left: 8),
            Expanded(
              child: Container(
                height: epgStore.timelineHeight + 40,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDateSelectorItem(
                              context: context,
                              label: language.yesterday,
                              dateStr: epgStore.dates.isNotEmpty ? epgStore.dates[0] : '',
                              index: 0,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey[800],
                          ),
                          Expanded(
                            child: _buildDateSelectorItem(
                              context: context,
                              label: language.today,
                              dateStr: epgStore.dates.length > 1 ? epgStore.dates[1] : '',
                              index: 1,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey[800],
                          ),
                          Expanded(
                            child: _buildDateSelectorItem(
                              context: context,
                              label: language.tomorrow,
                              dateStr: epgStore.dates.length > 2 ? epgStore.dates[2] : '',
                              index: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: timelineScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Builder(
                          builder: (context) {
                            if (epgStore.timeSlots.isEmpty) {
                              return SizedBox();
                            }
                            int currentSlotIndex = epgStore.timeSlots.indexWhere((slot) => epgStore.isCurrentTimeSlot(slot));
                            double slotWidth = epgStore.timeSlotWidth;
                            return Stack(
                              children: [
                                if (currentSlotIndex >= 0)
                                  Positioned(
                                    left: currentSlotIndex * slotWidth,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 3,
                                      height: epgStore.timelineHeight,
                                      color: context.primaryColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                Row(
                                  children: epgStore.timeSlots.map((timeSlot) {
                                    final isCurrentTimeSlot = epgStore.isCurrentTimeSlot(timeSlot);
                                    return Container(
                                      width: slotWidth,
                                      height: epgStore.timelineHeight,
                                      decoration: BoxDecoration(
                                        color: isCurrentTimeSlot ? context.primaryColor : const Color(0xFF2A2A2A),
                                        border: Border(
                                          right: BorderSide(color: Colors.grey[800]!, width: 0.5),
                                          bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          timeSlot,
                                          style: boldTextStyle(size: 14, color: isCurrentTimeSlot ? Colors.white : Colors.white70),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectorItem({
    required BuildContext context,
    required String label,
    required String dateStr,
    required int index,
  }) {
    final isSelected = dateStr == epgStore.selectedDate.value;

    return GestureDetector(
      onTap: () {
        if (dateStr.isNotEmpty) {
          onDateSelected.call(index);
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: isSelected ? context.primaryColor : Colors.transparent),
        child: Center(
          child: Text(
            label,
            style: boldTextStyle(size: 14, color: isSelected ? Colors.white : Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class CurrentTimeLineIndicator extends StatelessWidget {
  final double height;

  const CurrentTimeLineIndicator({required this.height});

  double _getCurrentTimeOffset() {
    if (epgStore.selectedDateIndex != 1) return -1;
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    return minutes * epgStore.pixelsPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    final offset = _getCurrentTimeOffset();
    if (offset < 0) return SizedBox.shrink();
    final slotWidth = epgStore.timeSlotWidth;
    final slotIndex = (offset / slotWidth).floor();
    final snappedOffset = slotIndex * slotWidth;
    return Positioned(
      left: snappedOffset,
      top: 0,
      bottom: 0,
      child: Container(width: 2, height: height, color: context.primaryColor),
    );
  }
}
