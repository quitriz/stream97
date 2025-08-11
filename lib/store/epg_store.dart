import 'package:mobx/mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/live_tv/epg_data_model.dart';

part 'epg_store.g.dart';

class EPGStore = _EPGStore with _$EPGStore;

abstract class _EPGStore with Store {
  @observable
  double channelColumnWidth = 120.0;

  @observable
  double timeSlotWidth = 100.0;

  @observable
  double channelRowHeight = 80.0;

  @observable
  double timelineHeight = 40.0;

  int get minutesPerSlot => 30;

  double get pixelsPerMinute => timeSlotWidth / minutesPerSlot;

  @observable
  EpgDataModel? epgData;

  @observable
  int currentChannelId = 0;

  @observable
  int selectedDateIndex = 1;

  @observable
  EpgDataModel? yesterdayData;

  @observable
  EpgDataModel? todayData;

  @observable
  EpgDataModel? tomorrowData;

  final dates = ObservableList<String>();

  final selectedDate = Observable<String>(
    DateTime.now().toIso8601String().split('T')[0],
  );

  @action
  void initializeDates() {
    final now = DateTime.now();
    dates.clear();
    dates.addAll([
      now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0], // Yesterday
      now.toIso8601String().split('T')[0],
      now.add(const Duration(days: 1)).toIso8601String().split('T')[0],
    ]);
  }

  @action
  void setSelectedDate(String date) {
    selectedDate.value = date;
  }

  @computed
  String get currentDateString {
    final now = DateTime.now();
    switch (selectedDateIndex) {
      case 0:
        return now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      case 1:
        return now.toIso8601String().split('T')[0];
      case 2:
        return now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
      default:
        return now.toIso8601String().split('T')[0];
    }
  }

  DateTime? _parseUserTime(String? userTime) {
    if (userTime == null || userTime.isEmpty) return null;
    try {
      if (userTime.contains('AM') || userTime.contains('PM')) {
        final format = DateFormat('h:mm a');
        final parsedTime = format.parse(userTime);
        final selectedDate = availableDates[selectedDateIndex];
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } else {
        final parts = userTime.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final selectedDate = availableDates[selectedDateIndex];
          return DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            hour,
            minute,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseTimestamp(int? timestamp) {
    if (timestamp == null) return null;
    try {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } catch (e) {
      return null;
    }
  }

  @action
  void setEpgData({
    EpgDataModel? yesterday,
    EpgDataModel? today,
    EpgDataModel? tomorrow,
  }) {
    yesterdayData = yesterday;
    todayData = today;
    tomorrowData = tomorrow;
    epgData = getCurrentDayData();
  }

  @action
  EpgDataModel? getCurrentDayData() {
    switch (selectedDateIndex) {
      case 0:
        epgData = yesterdayData;
        break;
      case 1:
        epgData = todayData;
        break;
      case 2:
        epgData = tomorrowData;
        break;
      default:
        epgData = todayData;
    }
    return epgData;
  }

  @action
  void setSelectedDateIndex(int index) {
    selectedDateIndex = index;
    selectedDate.value = currentDateString;
    epgData = getCurrentDayData();
  }

  @observable
  bool isScrolling = false;

  @observable
  double currentScrollOffset = 0.0;

  @observable
  double currentVerticalOffset = 0.0;

  @action
  void setSelectedDateAndIndex(String date, int index) {
    try {
      selectedDate.value = date;
      selectedDateIndex = index;
      epgData = getCurrentDayData();
    } catch (e) {
      toast("Error -> ${e.toString()}", print: true);
    }
  }

  @computed
  List<DateTime> get availableDates {
    final now = DateTime.now();
    return [
      DateTime(now.year, now.month, now.day - 1),
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day + 1),
    ];
  }

  @computed
  DateTime get dayStartTime {
    final selectedDate = availableDates[selectedDateIndex];
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
  }

  @computed
  List<String> get timeSlots {
    final slots = <String>[];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = DateTime(2024, 1, 1, hour, minute);
        // Format with AM/PM
        slots.add(DateFormat('h:mm a').format(time));
      }
    }
    return slots;
  }

  @computed
  List<EpgChannel> get channels => epgData?.data?.channels ?? [];

  @computed
  bool get hasData => channels.isNotEmpty;

  @computed
  double get appropriateScrollOffset {
    if (selectedDateIndex == 1) {
      final now = DateTime.now();
      final totalMinutes = now.hour * 60 + now.minute;
      final timeSlotIndex = totalMinutes ~/ 30;
      return timeSlotIndex * timeSlotWidth;
    } else {
      return 0.0;
    }
  }

  @action
  void setCurrentChannelId(int channelId) {
    currentChannelId = channelId;
  }

  @action
  void setScrolling(bool scrolling) {
    isScrolling = scrolling;
  }

  @action
  void updateScrollOffset(double offset) {
    if (!isScrolling) {
      currentScrollOffset = offset;
    }
  }

  @action
  void updateVerticalOffset(double offset) {
    if (!isScrolling) {
      currentVerticalOffset = offset;
    }
  }

  @computed
  Map<int, List<PositionedProgram>> get positionedProgramsByChannel {
    final result = <int, List<PositionedProgram>>{};

    for (final channel in channels) {
      result[channel.id!.validate()] = _buildPositionedProgramsForChannel(channel);
    }

    return result;
  }

  List<PositionedProgram> _buildPositionedProgramsForChannel(EpgChannel channel) {
    final date = availableDates[selectedDateIndex];
    final List<Program> rawPrograms = (channel.programs ?? []).where((program) {
      final id = program.id.validate();
      final programDate = _parseFormattedTime(program.startTimeFormatted, date);
      return id.isNotEmpty && programDate != null && programDate.year == date.year && programDate.month == date.month && programDate.day == date.day;
    }).toList();

    rawPrograms.sort((a, b) {
      final aStart = _parseFormattedTime(a.startTimeFormatted, date);
      final bStart = _parseFormattedTime(b.startTimeFormatted, date);
      if (aStart == null || bStart == null) return 0;
      return aStart.compareTo(bStart);
    });

    final List<Program> filteredPrograms = [];
    DateTime? lastEnd;
    for (final program in rawPrograms) {
      final start = _parseFormattedTime(program.startTimeFormatted, date);
      final end = _parseFormattedTime(program.endTimeFormatted, date);
      if (start == null || end == null) continue;
      if (lastEnd == null || start.isAtSameMomentAs(lastEnd) || start.isAfter(lastEnd)) {
        filteredPrograms.add(program);
        lastEnd = end;
      } else if (end.isAfter(lastEnd)) {
        filteredPrograms.removeLast();
        filteredPrograms.add(program);
        lastEnd = end;
      }
    }

    if (filteredPrograms.isEmpty) {
      return [PositionedProgram.empty(timeSlotWidth)];
    }

    final positionedPrograms = <PositionedProgram>[];
    double currentPosition = 0.0;
    final midnight = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final totalDayWidth = 24 * 60 * pixelsPerMinute;

    for (final program in filteredPrograms) {
      final start = _parseFormattedTime(program.startTimeFormatted, date) ?? midnight;
      final programPosition = ((start.difference(midnight).inMinutes) * pixelsPerMinute).toDouble();
      final programWidth = _calculateProgramWidth(program);

      if (programPosition > currentPosition) {
        final gapWidth = programPosition - currentPosition;
        positionedPrograms.add(PositionedProgram.gap(gapWidth));
        currentPosition = programPosition;
      }

      positionedPrograms.add(PositionedProgram.program(program, programWidth));
      currentPosition += programWidth;
    }

    if (currentPosition < totalDayWidth) {
      final remainingWidth = totalDayWidth - currentPosition;
      positionedPrograms.add(PositionedProgram.gap(remainingWidth));
    }

    return positionedPrograms;
  }

  DateTime? _parseFormattedTime(String? timeStr, DateTime date) {
    if (timeStr == null) return null;

    try {
      DateTime parsedTime;

      if (timeStr.contains(RegExp(r'[AaPp][Mm]'))) {
        parsedTime = DateFormat.jm().parse(timeStr);
      } else {
        parsedTime = DateFormat.Hm().parse(timeStr);
      }

      return DateTime(
        date.year,
        date.month,
        date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      log('❌ Failed to parse time: $timeStr');
      return null;
    }
  }

  double _calculateProgramWidth(Program program) {
    DateTime? programStartTime, programEndTime;

    if (program.startTime != null && program.endTime != null) {
      programStartTime = _parseTimestamp(program.startTime);
      programEndTime = _parseTimestamp(program.endTime);
    } else {
      programStartTime = _parseUserTime(program.userStartTime);
      programEndTime = _parseUserTime(program.userEndTime);
    }

    if (programStartTime == null || programEndTime == null) {
      return timeSlotWidth;
    }

    final durationMinutes = programEndTime.difference(programStartTime).inMinutes.toDouble();
    final width = durationMinutes * pixelsPerMinute;
    return width;
  }

  bool isProgramCurrent(Program program) {
    if (selectedDateIndex != 1) return false;

    final now = DateTime.now();
    final date = availableDates[selectedDateIndex];
    final programStartTime = _parseFormattedTime(program.startTimeFormatted, date);
    final programEndTime = _parseFormattedTime(program.endTimeFormatted, date);

    if (programStartTime == null || programEndTime == null) return false;

    return (now.isAfter(programStartTime) && now.isBefore(programEndTime)) || now.isAtSameMomentAs(programStartTime);
  }

  bool isCurrentTimeSlot(String timeSlot) {
    if (selectedDateIndex != 1) return false;

    final now = DateTime.now();
    try {
      final slotTime = DateFormat('h:mm a').parse(timeSlot);
      final currentTotalMinutes = now.hour * 60 + now.minute;
      final slotTotalMinutes = slotTime.hour * 60 + slotTime.minute;

      return currentTotalMinutes >= slotTotalMinutes && currentTotalMinutes < (slotTotalMinutes + 30);
    } catch (e) {
      return false;
    }
  }
}

class PositionedProgram {
  final Program? program;
  final double width;
  final bool isEmpty;
  final bool isGap;

  PositionedProgram._({
    this.program,
    required this.width,
    this.isEmpty = false,
    this.isGap = false,
  });

  factory PositionedProgram.program(Program program, double width) {
    return PositionedProgram._(program: program, width: width);
  }

  factory PositionedProgram.empty(double timeSlotWidth) {
    return PositionedProgram._(width: timeSlotWidth, isEmpty: true);
  }

  factory PositionedProgram.gap(double width) {
    return PositionedProgram._(width: width, isGap: true);
  }
}
