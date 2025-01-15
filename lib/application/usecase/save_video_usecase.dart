import 'package:bebikame/model/result.dart';
import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/video_service.dart';

class SaveVideoUsecase {
  final _videoService = getIt<VideoService>();

  Future<Result> execute(String? videoPath) async {
    try {
      if (videoPath == null) {
        return const Failure('撮影した動画が見つからないため保存できませんでした。');
      }

      await _videoService.saveVideo(videoPath);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString(), e as Exception?);
    }
  }
}
