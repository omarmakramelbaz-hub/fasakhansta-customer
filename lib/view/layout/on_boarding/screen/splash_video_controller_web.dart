// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createOpeningVideoController(String encoded) async {
  final bytes = base64Decode(encoded);
  final blob = html.Blob(<dynamic>[bytes], 'video/mp4');
  final url = html.Url.createObjectUrlFromBlob(blob);
  return VideoPlayerController.networkUrl(
    Uri.parse(url),
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
}
