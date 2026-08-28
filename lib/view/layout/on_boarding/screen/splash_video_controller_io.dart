import 'dart:convert';
import 'dart:io';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createOpeningVideoController(String encoded) async {
  final bytes = base64Decode(encoded);
  final file = File('${Directory.systemTemp.path}/fasakhansta_opening.mp4');
  await file.writeAsBytes(bytes, flush: true);
  return VideoPlayerController.file(
    file,
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
}
