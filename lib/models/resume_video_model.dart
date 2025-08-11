class ContinueWatchModel {
  int watchedTime;
  int watchedTotalTime;
  int watchedTimePercentage;

  ContinueWatchModel({
    this.watchedTime = -1,
    this.watchedTotalTime = -1,
    this.watchedTimePercentage = -1,
  });

  factory ContinueWatchModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchModel(
      watchedTime: json['watched_time'] is int ? json['watched_time'] : -1,
      watchedTotalTime:
      json['watched_total_time'] is int ? json['watched_total_time'] : -1,
      watchedTimePercentage: json['watched_time_percentage'] is int
          ? json['watched_time_percentage']
          : -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watched_time': watchedTime,
      'watched_total_time': watchedTotalTime,
      'watched_time_percentage': watchedTimePercentage,
    };
  }
}