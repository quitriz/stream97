// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$EPGStore on _EPGStore, Store {
  Computed<String>? _$currentDateStringComputed;

  @override
  String get currentDateString => (_$currentDateStringComputed ??=
          Computed<String>(() => super.currentDateString,
              name: '_EPGStore.currentDateString'))
      .value;
  Computed<List<DateTime>>? _$availableDatesComputed;

  @override
  List<DateTime> get availableDates => (_$availableDatesComputed ??=
          Computed<List<DateTime>>(() => super.availableDates,
              name: '_EPGStore.availableDates'))
      .value;
  Computed<DateTime>? _$dayStartTimeComputed;

  @override
  DateTime get dayStartTime =>
      (_$dayStartTimeComputed ??= Computed<DateTime>(() => super.dayStartTime,
              name: '_EPGStore.dayStartTime'))
          .value;
  Computed<List<String>>? _$timeSlotsComputed;

  @override
  List<String> get timeSlots =>
      (_$timeSlotsComputed ??= Computed<List<String>>(() => super.timeSlots,
              name: '_EPGStore.timeSlots'))
          .value;
  Computed<List<EpgChannel>>? _$channelsComputed;

  @override
  List<EpgChannel> get channels =>
      (_$channelsComputed ??= Computed<List<EpgChannel>>(() => super.channels,
              name: '_EPGStore.channels'))
          .value;
  Computed<bool>? _$hasDataComputed;

  @override
  bool get hasData => (_$hasDataComputed ??=
          Computed<bool>(() => super.hasData, name: '_EPGStore.hasData'))
      .value;
  Computed<double>? _$appropriateScrollOffsetComputed;

  @override
  double get appropriateScrollOffset => (_$appropriateScrollOffsetComputed ??=
          Computed<double>(() => super.appropriateScrollOffset,
              name: '_EPGStore.appropriateScrollOffset'))
      .value;
  Computed<Map<int, List<PositionedProgram>>>?
      _$positionedProgramsByChannelComputed;

  @override
  Map<int, List<PositionedProgram>> get positionedProgramsByChannel =>
      (_$positionedProgramsByChannelComputed ??=
              Computed<Map<int, List<PositionedProgram>>>(
                  () => super.positionedProgramsByChannel,
                  name: '_EPGStore.positionedProgramsByChannel'))
          .value;

  late final _$channelColumnWidthAtom =
      Atom(name: '_EPGStore.channelColumnWidth', context: context);

  @override
  double get channelColumnWidth {
    _$channelColumnWidthAtom.reportRead();
    return super.channelColumnWidth;
  }

  @override
  set channelColumnWidth(double value) {
    _$channelColumnWidthAtom.reportWrite(value, super.channelColumnWidth, () {
      super.channelColumnWidth = value;
    });
  }

  late final _$timeSlotWidthAtom =
      Atom(name: '_EPGStore.timeSlotWidth', context: context);

  @override
  double get timeSlotWidth {
    _$timeSlotWidthAtom.reportRead();
    return super.timeSlotWidth;
  }

  @override
  set timeSlotWidth(double value) {
    _$timeSlotWidthAtom.reportWrite(value, super.timeSlotWidth, () {
      super.timeSlotWidth = value;
    });
  }

  late final _$channelRowHeightAtom =
      Atom(name: '_EPGStore.channelRowHeight', context: context);

  @override
  double get channelRowHeight {
    _$channelRowHeightAtom.reportRead();
    return super.channelRowHeight;
  }

  @override
  set channelRowHeight(double value) {
    _$channelRowHeightAtom.reportWrite(value, super.channelRowHeight, () {
      super.channelRowHeight = value;
    });
  }

  late final _$timelineHeightAtom =
      Atom(name: '_EPGStore.timelineHeight', context: context);

  @override
  double get timelineHeight {
    _$timelineHeightAtom.reportRead();
    return super.timelineHeight;
  }

  @override
  set timelineHeight(double value) {
    _$timelineHeightAtom.reportWrite(value, super.timelineHeight, () {
      super.timelineHeight = value;
    });
  }

  late final _$epgDataAtom = Atom(name: '_EPGStore.epgData', context: context);

  @override
  EpgDataModel? get epgData {
    _$epgDataAtom.reportRead();
    return super.epgData;
  }

  @override
  set epgData(EpgDataModel? value) {
    _$epgDataAtom.reportWrite(value, super.epgData, () {
      super.epgData = value;
    });
  }

  late final _$currentChannelIdAtom =
      Atom(name: '_EPGStore.currentChannelId', context: context);

  @override
  int get currentChannelId {
    _$currentChannelIdAtom.reportRead();
    return super.currentChannelId;
  }

  @override
  set currentChannelId(int value) {
    _$currentChannelIdAtom.reportWrite(value, super.currentChannelId, () {
      super.currentChannelId = value;
    });
  }

  late final _$selectedDateIndexAtom =
      Atom(name: '_EPGStore.selectedDateIndex', context: context);

  @override
  int get selectedDateIndex {
    _$selectedDateIndexAtom.reportRead();
    return super.selectedDateIndex;
  }

  @override
  set selectedDateIndex(int value) {
    _$selectedDateIndexAtom.reportWrite(value, super.selectedDateIndex, () {
      super.selectedDateIndex = value;
    });
  }

  late final _$yesterdayDataAtom =
      Atom(name: '_EPGStore.yesterdayData', context: context);

  @override
  EpgDataModel? get yesterdayData {
    _$yesterdayDataAtom.reportRead();
    return super.yesterdayData;
  }

  @override
  set yesterdayData(EpgDataModel? value) {
    _$yesterdayDataAtom.reportWrite(value, super.yesterdayData, () {
      super.yesterdayData = value;
    });
  }

  late final _$todayDataAtom =
      Atom(name: '_EPGStore.todayData', context: context);

  @override
  EpgDataModel? get todayData {
    _$todayDataAtom.reportRead();
    return super.todayData;
  }

  @override
  set todayData(EpgDataModel? value) {
    _$todayDataAtom.reportWrite(value, super.todayData, () {
      super.todayData = value;
    });
  }

  late final _$tomorrowDataAtom =
      Atom(name: '_EPGStore.tomorrowData', context: context);

  @override
  EpgDataModel? get tomorrowData {
    _$tomorrowDataAtom.reportRead();
    return super.tomorrowData;
  }

  @override
  set tomorrowData(EpgDataModel? value) {
    _$tomorrowDataAtom.reportWrite(value, super.tomorrowData, () {
      super.tomorrowData = value;
    });
  }

  late final _$isScrollingAtom =
      Atom(name: '_EPGStore.isScrolling', context: context);

  @override
  bool get isScrolling {
    _$isScrollingAtom.reportRead();
    return super.isScrolling;
  }

  @override
  set isScrolling(bool value) {
    _$isScrollingAtom.reportWrite(value, super.isScrolling, () {
      super.isScrolling = value;
    });
  }

  late final _$currentScrollOffsetAtom =
      Atom(name: '_EPGStore.currentScrollOffset', context: context);

  @override
  double get currentScrollOffset {
    _$currentScrollOffsetAtom.reportRead();
    return super.currentScrollOffset;
  }

  @override
  set currentScrollOffset(double value) {
    _$currentScrollOffsetAtom.reportWrite(value, super.currentScrollOffset, () {
      super.currentScrollOffset = value;
    });
  }

  late final _$currentVerticalOffsetAtom =
      Atom(name: '_EPGStore.currentVerticalOffset', context: context);

  @override
  double get currentVerticalOffset {
    _$currentVerticalOffsetAtom.reportRead();
    return super.currentVerticalOffset;
  }

  @override
  set currentVerticalOffset(double value) {
    _$currentVerticalOffsetAtom.reportWrite(value, super.currentVerticalOffset,
        () {
      super.currentVerticalOffset = value;
    });
  }

  late final _$_EPGStoreActionController =
      ActionController(name: '_EPGStore', context: context);

  @override
  void initializeDates() {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.initializeDates');
    try {
      return super.initializeDates();
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDate(String date) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.setSelectedDate');
    try {
      return super.setSelectedDate(date);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEpgData(
      {EpgDataModel? yesterday, EpgDataModel? today, EpgDataModel? tomorrow}) {
    final _$actionInfo =
        _$_EPGStoreActionController.startAction(name: '_EPGStore.setEpgData');
    try {
      return super
          .setEpgData(yesterday: yesterday, today: today, tomorrow: tomorrow);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  EpgDataModel? getCurrentDayData() {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.getCurrentDayData');
    try {
      return super.getCurrentDayData();
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDateIndex(int index) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.setSelectedDateIndex');
    try {
      return super.setSelectedDateIndex(index);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDateAndIndex(String date, int index) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.setSelectedDateAndIndex');
    try {
      return super.setSelectedDateAndIndex(date, index);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentChannelId(int channelId) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.setCurrentChannelId');
    try {
      return super.setCurrentChannelId(channelId);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setScrolling(bool scrolling) {
    final _$actionInfo =
        _$_EPGStoreActionController.startAction(name: '_EPGStore.setScrolling');
    try {
      return super.setScrolling(scrolling);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateScrollOffset(double offset) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.updateScrollOffset');
    try {
      return super.updateScrollOffset(offset);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateVerticalOffset(double offset) {
    final _$actionInfo = _$_EPGStoreActionController.startAction(
        name: '_EPGStore.updateVerticalOffset');
    try {
      return super.updateVerticalOffset(offset);
    } finally {
      _$_EPGStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
channelColumnWidth: ${channelColumnWidth},
timeSlotWidth: ${timeSlotWidth},
channelRowHeight: ${channelRowHeight},
timelineHeight: ${timelineHeight},
epgData: ${epgData},
currentChannelId: ${currentChannelId},
selectedDateIndex: ${selectedDateIndex},
yesterdayData: ${yesterdayData},
todayData: ${todayData},
tomorrowData: ${tomorrowData},
isScrolling: ${isScrolling},
currentScrollOffset: ${currentScrollOffset},
currentVerticalOffset: ${currentVerticalOffset},
currentDateString: ${currentDateString},
availableDates: ${availableDates},
dayStartTime: ${dayStartTime},
timeSlots: ${timeSlots},
channels: ${channels},
hasData: ${hasData},
appropriateScrollOffset: ${appropriateScrollOffset},
positionedProgramsByChannel: ${positionedProgramsByChannel}
    ''';
  }
}
