import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createOpeningVideoController(
  List<String> chunkPaths,
) async {
  final chunks = await Future.wait(chunkPaths.map(rootBundle.loadString));
  final encoded = chunks
      .map((chunk) => chunk.replaceAll(RegExp(r'\s+'), ''))
      .join();

  return VideoPlayerController.networkUrl(
    Uri.parse('data:video/mp4;base64,$encoded'),
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
}
