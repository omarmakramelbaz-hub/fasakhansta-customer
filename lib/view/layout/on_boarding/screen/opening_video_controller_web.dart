import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createOpeningVideoController(
  List<String> chunkPaths,
) async {
  final chunks = await Future.wait(chunkPaths.map(rootBundle.loadString));
  final encoded = chunks
      .map((chunk) => chunk.replaceAll(RegExp(r'\s+'), ''))
      .join();
  final bytes = base64Decode(encoded);
  final blob = html.Blob(<Object>[bytes], 'video/mp4');
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);

  return VideoPlayerController.networkUrl(
    Uri.parse(objectUrl),
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
}
