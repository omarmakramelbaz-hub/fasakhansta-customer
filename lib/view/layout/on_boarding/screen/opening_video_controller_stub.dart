import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createOpeningVideoController(
  List<String> chunkPaths,
) {
  throw UnsupportedError('Opening video is not supported on this platform.');
}
