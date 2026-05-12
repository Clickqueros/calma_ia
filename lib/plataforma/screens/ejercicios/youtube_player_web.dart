// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final _registered = <String>{};

Widget buildYoutubePlayer(String videoId) {
  final viewType = 'yt-$videoId';
  if (!_registered.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int id) {
      return html.IFrameElement()
        ..src =
            'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1&controls=1'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute(
          'allow',
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share',
        )
        ..allowFullscreen = true;
    });
    _registered.add(viewType);
  }
  return HtmlElementView(viewType: viewType);
}
