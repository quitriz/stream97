import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/live_tv/epg_data_model.dart';
import 'package:streamit_flutter/screens/live_tv/epg_components/epg_shimmer_component.dart';
import 'package:streamit_flutter/screens/live_tv/epg_components/epg_timeline_header_item_component.dart';
import 'epg_channel_item_component.dart';
import 'epg_program_item_component.dart';

class EPGGridComponent extends StatefulWidget {
  final int currentChannelId;
  final Function(int channelId)? onChannelTap;
  final Function(String programId, int channelId)? onProgramTap;
  final EpgDataModel? epgYesterday;
  final EpgDataModel? epgToday;
  final EpgDataModel? epgTomorrow;

  const EPGGridComponent({Key? key, required this.currentChannelId, this.onChannelTap, this.onProgramTap, this.epgYesterday, this.epgToday, this.epgTomorrow}) : super(key: key);

  @override
  State<EPGGridComponent> createState() => _EPGGridComponentState();
}

class _EPGGridComponentState extends State<EPGGridComponent> {
  late ScrollController _verticalScrollController;
  late ScrollController _channelsScrollController;
  late ScrollController _timelineScrollController;
  late List<ScrollController> _programScrollControllers;
  bool _isInitialized = false;
  bool _hasAutoScrolled = false;

//region init
  @override
  void initState() {
    super.initState();
    epgStore.initializeDates();
    if (epgStore.dates.isNotEmpty) {
      epgStore.setSelectedDateAndIndex(epgStore.dates[1], 1);
    }
    _initializeStore();
    _initializeScrollControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScrollToCurrentTime());
  }

  void _initializeStore() {
    epgStore.setEpgData(today: widget.epgToday, yesterday: widget.epgYesterday, tomorrow: widget.epgTomorrow);
    epgStore.setCurrentChannelId(widget.currentChannelId);
  }

//endregion

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hasAutoScrolled = false;
  }

  @override
  void didUpdateWidget(EPGGridComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool dataChanged = false;

    if (oldWidget.epgYesterday != widget.epgYesterday || oldWidget.epgToday != widget.epgToday || oldWidget.epgTomorrow != widget.epgTomorrow) {
      epgStore.setEpgData(yesterday: widget.epgYesterday, today: widget.epgToday, tomorrow: widget.epgTomorrow);
      dataChanged = true;
    }

    if (oldWidget.currentChannelId != widget.currentChannelId) {
      epgStore.setCurrentChannelId(widget.currentChannelId);
    }

    if (dataChanged && _programScrollControllers.length != epgStore.channels.length) {
      _initializeScrollControllers();
    }
  }

//region Scroll Controllers
  void _initializeScrollControllers() {
    if (_isInitialized) {
      _disposeScrollControllers();
    }

    _verticalScrollController = ScrollController();
    _channelsScrollController = ScrollController();
    _timelineScrollController = ScrollController();
    _programScrollControllers = [];

    final channelCount = epgStore.channels.length;
    for (int i = 0; i < channelCount; i++) {
      final controller = ScrollController();
      _programScrollControllers.add(controller);

      controller.addListener(() {
        if (!epgStore.isScrolling && controller.hasClients) {
          epgStore.updateScrollOffset(controller.offset);
          _syncScrollControllers(controller.offset, i);
        }
      });
    }

    _timelineScrollController.addListener(() {
      if (!epgStore.isScrolling && _timelineScrollController.hasClients) {
        epgStore.updateScrollOffset(_timelineScrollController.offset);
        _syncScrollControllers(_timelineScrollController.offset, -1);
      }
    });

    _verticalScrollController.addListener(() {
      if (!epgStore.isScrolling && _verticalScrollController.hasClients) {
        epgStore.updateVerticalOffset(_verticalScrollController.offset);
        _syncVerticalScrollControllers(_verticalScrollController.offset, false);
      }
    });

    _channelsScrollController.addListener(() {
      if (!epgStore.isScrolling && _channelsScrollController.hasClients) {
        epgStore.updateVerticalOffset(_channelsScrollController.offset);
        _syncVerticalScrollControllers(_channelsScrollController.offset, true);
      }
    });

    _isInitialized = true;
  }

  void _syncVerticalScrollControllers(double offset, bool isFromChannels) {
    if (epgStore.isScrolling) return;

    epgStore.setScrolling(true);

    try {
      if (isFromChannels && _verticalScrollController.hasClients) {
        final maxScrollExtent = _verticalScrollController.position.maxScrollExtent;
        final clampedOffset = offset.clamp(0.0, maxScrollExtent);
        if ((_verticalScrollController.offset - clampedOffset).abs() > 1.0) {
          _verticalScrollController.jumpTo(clampedOffset);
        }
      } else if (!isFromChannels && _channelsScrollController.hasClients) {
        final maxScrollExtent = _channelsScrollController.position.maxScrollExtent;
        final clampedOffset = offset.clamp(0.0, maxScrollExtent);
        if ((_channelsScrollController.offset - clampedOffset).abs() > 1.0) {
          _channelsScrollController.jumpTo(clampedOffset);
        }
      }
    } catch (e) {
      log('Error syncing vertical scroll controllers: $e');
    } finally {
      epgStore.setScrolling(false);
    }
  }

  void _syncScrollControllers(double offset, int sourceIndex) {
    if (epgStore.isScrolling) return;

    epgStore.setScrolling(true);

    try {
      if (sourceIndex != -1 && _timelineScrollController.hasClients) {
        final maxScrollExtent = _timelineScrollController.position.maxScrollExtent;
        final clampedOffset = offset.clamp(0.0, maxScrollExtent);
        if ((_timelineScrollController.offset - clampedOffset).abs() > 1.0) {
          _timelineScrollController.jumpTo(clampedOffset);
        }
      }

      for (int i = 0; i < _programScrollControllers.length; i++) {
        if (i != sourceIndex && _programScrollControllers[i].hasClients) {
          final maxScrollExtent = _programScrollControllers[i].position.maxScrollExtent;
          final clampedOffset = offset.clamp(0.0, maxScrollExtent);
          if ((_programScrollControllers[i].offset - clampedOffset).abs() > 1.0) {
            _programScrollControllers[i].jumpTo(clampedOffset);
          }
        }
      }
    } catch (e) {
      log('Error syncing scroll controllers: $e');
    } finally {
      epgStore.setScrolling(false);
    }
  }

  void _autoScrollToCurrentTime() {
    if (_hasAutoScrolled) return;
    if (!mounted) return;
    if (epgStore.selectedDateIndex != 1) return;
    final offset = epgStore.appropriateScrollOffset;
    if (_timelineScrollController.hasClients) {
      _timelineScrollController.jumpTo(offset);
    }
    for (final controller in _programScrollControllers) {
      if (controller.hasClients) {
        controller.jumpTo(offset);
      }
    }
    _hasAutoScrolled = true;
  }

  void _disposeScrollControllers() {
    _verticalScrollController.dispose();
    _channelsScrollController.dispose();
    _timelineScrollController.dispose();
    for (final controller in _programScrollControllers) {
      controller.dispose();
    }
    _programScrollControllers.clear();
  }

  //endregion

  @override
  void dispose() {
    _disposeScrollControllers();
    super.dispose();
  }

//region Helper methods
  double _getCurrentTimeOffset() {
    if (epgStore.selectedDateIndex != 1) return -1;
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    return minutes * epgStore.pixelsPerMinute;
  }

  double _pixelsForTime(DateTime time, DateTime dayStart, double pixelsPerMinute) {
    final minutesSinceStart = time.difference(dayStart).inMinutes.clamp(0, 24 * 60);
    return minutesSinceStart * pixelsPerMinute;
  }

  DateTime? _parseFormattedTime(String? timeStr, DateTime date) {
    if (timeStr == null) return null;

    try {
      final parsedTime = DateFormat.jm().parse(timeStr);
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      return null;
    }
  }

//endregion

  /// List of positioned programs for the given channel's programs.
  List<PositionedProgram> _buildPositionedPrograms(
    List<Program> programs, {
    required DateTime dayStart,
    required double pixelsPerMinute,
  }) {
    final List<PositionedProgram> positioned = [];

    for (final prog in programs) {
      final start = _parseFormattedTime(prog.startTimeFormatted, dayStart)!;
      final end = _parseFormattedTime(prog.endTimeFormatted, dayStart)!;

      final startPx = _pixelsForTime(start, dayStart, pixelsPerMinute);
      final widthPx = _pixelsForTime(end, dayStart, pixelsPerMinute) - startPx;

      positioned.add(PositionedProgram(
        program: prog,
        startPixel: startPx,
        width: widthPx > 0 ? widthPx : 1,
        isEmpty: false,
        isGap: false,
      ));
    }

    positioned.sort((a, b) => a.startPixel.compareTo(b.startPixel));

    return positioned;
  }

  Widget _buildPositionedProgramWidget(PositionedProgram positionedProgram, int channelId) {
    if (positionedProgram.program != null) {
      return EpgProgramItemComponent(
        pp: positionedProgram,
        channelId: channelId,
        onProgramTap: (programId, channelId) {
          widget.onProgramTap?.call(programId, channelId);
        },
        onChannelTap: (channelId) {
          widget.onChannelTap?.call(channelId);
        },
      );
    }

    return Container(
      width: positionedProgram.width,
      height: epgStore.channelRowHeight,
      margin: const EdgeInsets.only(right: 2, bottom: 6, top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
            language!.noProgramsAvailable,
          style: secondaryTextStyle(size: 10, color: Colors.white30),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeLine({required double height}) {
    final offset = _getCurrentTimeOffset();
    if (offset < 0) return SizedBox.shrink();
    return Positioned(
      left: offset,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        height: height,
        color: context.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        try {
          if (!epgStore.hasData) {
            return EPGShimmerComponent();
          }
          if (_programScrollControllers.length != epgStore.channels.length) {
            _initializeScrollControllers();
          }
          return Container(
            height: context.height() * 0.6,
            color: Colors.black,
            child: Column(
              children: [
                EPGTimelineHeaderWidget(
                  timelineScrollController: _timelineScrollController,
                  onDateSelected: (index) {
                    if (epgStore.dates[index].isNotEmpty) {
                      epgStore.setSelectedDateAndIndex(epgStore.dates[index], index);

                      if (index == 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _hasAutoScrolled = false;
                          _autoScrollToCurrentTime();
                        });
                      }
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Channels
                        Container(
                          width: epgStore.channelColumnWidth - 10,
                          padding: const EdgeInsets.only(left: 8),
                          child: Scrollbar(
                            controller: _channelsScrollController,
                            trackVisibility: false,
                            thumbVisibility: false,
                            interactive: false,
                            thickness: 0,
                            child: SingleChildScrollView(
                              controller: _channelsScrollController,
                              physics: const ClampingScrollPhysics(),
                              child: Table(
                                columnWidths: {
                                  0: FixedColumnWidth(epgStore.channelColumnWidth - 10),
                                },
                                children: epgStore.channels.asMap().entries.map((entry) {
                                  final channel = entry.value;
                                  return TableRow(
                                    children: [
                                      TableCell(
                                        child: SizedBox(
                                          height: epgStore.channelRowHeight + 6,
                                          child: EPGChannelItemComponent(
                                            channel: EpgChannel(
                                              id: channel.id,
                                              title: channel.title,
                                              thumbnailImage: channel.thumbnailImage,
                                            ),
                                            isSelected: channel.id == widget.currentChannelId,
                                            onChannelTap: (channelId) {
                                              widget.onChannelTap?.call(channelId);
                                              epgStore.setCurrentChannelId(channelId);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        8.width,

                        /// Programs
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalScrollController,
                            trackVisibility: false,
                            thumbVisibility: false,
                            interactive: false,
                            thickness: 0,
                            child: Table(
                              columnWidths: {
                                0: FlexColumnWidth(),
                              },
                              children: epgStore.channels.asMap().entries.map((entry) {
                                final channelIndex = entry.key;
                                final channel = entry.value;
                                final channelId = channel.id.validate();
                                final selectedDate = epgStore.availableDates[epgStore.selectedDateIndex];
                                final rawPrograms = channel.programs ?? [];
                                final filteredPrograms = rawPrograms.where((program) {
                                  final id = program.id.validate();
                                  final parsed = _parseFormattedTime(program.startTimeFormatted, selectedDate);
                                  return id.isNotEmpty && parsed != null && parsed.year == selectedDate.year && parsed.month == selectedDate.month && parsed.day == selectedDate.day;
                                }).toList();
                                final positionedPrograms = _buildPositionedPrograms(
                                  filteredPrograms,
                                  dayStart: selectedDate,
                                  pixelsPerMinute: epgStore.pixelsPerMinute,
                                );
                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: SizedBox(
                                        height: epgStore.channelRowHeight + 6,
                                        child: SingleChildScrollView(
                                          controller: channelIndex < _programScrollControllers.length ? _programScrollControllers[channelIndex] : null,
                                          scrollDirection: Axis.horizontal,
                                          physics: const ClampingScrollPhysics(),
                                          child: Stack(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: positionedPrograms.isNotEmpty
                                                    ? positionedPrograms.asMap().entries.map((entry) {
                                                        final idx = entry.key;
                                                        final positionedProgram = entry.value;
                                                        final isFirst = idx == 0 && positionedProgram.startPixel > 0;
                                                        return Container(
                                                          margin: EdgeInsets.only(left: isFirst ? positionedProgram.startPixel : 0),
                                                          child: _buildPositionedProgramWidget(positionedProgram, channelId),
                                                        );
                                                      }).toList()
                                                    : [
                                                        Container(
                                                          width: epgStore.timeSlotWidth * epgStore.timeSlots.length,
                                                          height: epgStore.channelRowHeight,
                                                          margin: const EdgeInsets.only(bottom: 6),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF0A0A0A),
                                                            border: Border(
                                                              right: BorderSide(color: Colors.grey[800]!, width: 0.5),
                                                              bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                                                            ),
                                                          ),
                                                          child:  Center(
                                                            child: Text(
                                                              language!.noProgramsAvailable,
                                                              style: TextStyle(fontSize: 10, color: Colors.white30),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                              ),
                                              _buildCurrentTimeLine(height: epgStore.channelRowHeight),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e, stack) {
          log('EPGGridComponent Observer error: $e\n$stack');
          return Container(
            height: 300,
            child: Center(
              child: Text(
                language!.noProgram,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }
      },
    );
  }
}

class PositionedProgram {
  final Program program;
  final double startPixel;
  final double width;
  final bool isEmpty;
  final bool isGap;

  PositionedProgram({
    required this.program,
    required this.startPixel,
    required this.width,
    this.isEmpty = false,
    this.isGap = false,
  });
}
