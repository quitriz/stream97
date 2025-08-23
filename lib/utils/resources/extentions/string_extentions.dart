import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:html/dom.dart' as dom;
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/main.dart';

import '../../constants.dart';

extension StExt on String {
  Widget iconImageColored({double? size, Color? color, BoxFit? fit, double? height, double? width, bool isRoundedCorner = false}) {
    return Image.asset(
      this,
      height: size ?? height ?? 24,
      width: size ?? width ?? 24,
      fit: fit ?? BoxFit.cover,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return PlaceHolderWidget();
      },
    ).cornerRadiusWithClipRRect(isRoundedCorner ? 8 : 0);
  }

  int getYear() {
    return DateTime.parse(this).year;
  }

  String? getFormattedDate({String format = defaultDateFormat}) {
    try {
      return DateFormat(format).format(DateTime.parse(this));
    } on FormatException catch (e) {
      return e.source;
    }
  }

  bool get isVideoPlayerFile => this.contains(".mp4") || this.contains(".m4v") || this.contains(".mkv") || this.contains(".mov");

  String get urlFromIframe {
    var document = parse(this);
    dom.Element? link = document.querySelector('iframe');
    String? iframeLink = link != null ? link.attributes['src'].validate() : '';
    return iframeLink.validate();
  }

  bool get isYoutubeUrl {
    final url = this.validate().trim();
    for (var exp in [
      // watch with v param in any order
      RegExp(r"^(?:https?:)?\/\/(?:www\.|m\.)?youtube\.com\/.*[?&]v=([_\-a-zA-Z0-9]{11}).*$", caseSensitive: false),
      // embed
      RegExp(r"^(?:https?:)?\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // youtu.be short
      RegExp(r"^(?:https?:)?\/\/youtu\.be\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // shorts
      RegExp(r"^(?:https?:)?\/\/(?:www\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // live
      RegExp(r"^(?:https?:)?\/\/(?:www\.)?youtube\.com\/live\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
    ]) {
      final match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return true;
    }
    return false;
  }

  bool get isLiveURL => this.contains(".m3u8");

  bool get isVimeoVideLink {
    final vimeoRegex = RegExp(r'vimeo\.com/(?:video/|)(\d+)(?:\?|$)');

    // Replace `url` with the actual URL you want to check

    return vimeoRegex.hasMatch(this);
  }

  String? get getVimeoVideoId {
    final regExp = RegExp(r'vimeo\.com/(?:video/|)(\d+)(?:\?|$)');
    final match = regExp.firstMatch(this);
    return match != null ? match.group(1) : '';
  }

  String getVideoId() {
    final regex = RegExp(r'^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&?]*).*');
    final match = regex.firstMatch(this);
    return match?.group(2) ?? '';
  }

  String getYouTubeId({bool trimWhitespaces = true}) {
    String url = this.validate();
    if (trimWhitespaces) url = url.trim();
    // If it's just the 11-char ID
    if (!url.contains('http') && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(url)) return url;

    for (var exp in [
      // watch with v param in any order
      RegExp(r"^(?:https?:)?\/\/(?:www\.|m\.)?youtube\.com\/.*[?&]v=([_\-a-zA-Z0-9]{11}).*$", caseSensitive: false),
      // embed
      RegExp(r"^(?:https?:)?\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // youtu.be short
      RegExp(r"^(?:https?:)?\/\/youtu\.be\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // shorts
      RegExp(r"^(?:https?:)?\/\/(?:www\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
      // live
      RegExp(r"^(?:https?:)?\/\/(?:www\.)?youtube\.com\/live\/([_\-a-zA-Z0-9]{11})(?:\?.*)?$", caseSensitive: false),
    ]) {
      final match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1)!;
    }
    // Fallback: generic extractor
    final generic = RegExp(r'(?:v=|\/)([A-Za-z0-9_-]{11})(?:(?:&|\?|\/).*)?$');
    final m = generic.firstMatch(url);
    if (m != null && m.groupCount >= 1) return m.group(1)!;
    return '';
  }

  String getURLType() {
    final value = this.validate().trim();
    if (value.isYoutubeUrl) {
      return VideoType.typeYoutube;
    } else if (value.contains('vimeo')) {
      return VideoType.typeVimeo;
    } else if (value.contains('/storage') || value.contains('/var/mobile/Containers/')) {
      return VideoType.typeFile;
    } else {
      return VideoType.typeURL;
    }
  }

  PlayVideoFrom getPlatformVideo() {
    if (this.validate().isYoutubeUrl) {
      return PlayVideoFrom.youtube(this.validate().getVideoId(), live: this.contains('live'));
    } else if (this.validate().contains('vimeo')) {
      return PlayVideoFrom.vimeo(this.validate().getVimeoVideoId.validate());
    } else if (this.validate().contains('/storage') || this.validate().contains('/var/mobile/Containers/')) {
      return PlayVideoFrom.file(File.fromUri(Uri.parse(this)));
    } else {
      return PlayVideoFrom.network(this.validate());
    }
  }

  String title() {
    switch (this) {
      case dashboardTypeHome:
        return language.home;
      case dashboardTypeTVShow:
        return language.tVShows;
      case dashboardTypeMovie:
        return language.movies;
      case dashboardTypeVideo:
        return language.videos;

      case dashboardTypeEpisode:
        return language.episode.capitalizeFirstLetter();
      default:
        return this;
    }
  }
}