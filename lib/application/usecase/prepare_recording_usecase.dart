import 'package:bebikame/model/result.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/permission_handler_service.dart';
import 'package:bebikame/service/video_service.dart';

class PrepareRecordingUsecase {
  final permissionHandlerService = getIt<PermissionHandlerService>();
  final videoService = getIt<VideoService>();
  final audioService = getIt<AudioService>();

  Future<Result> execute() async {
    try {
      final isAllPermissionsGranted =
          await permissionHandlerService.requestPermissions();

      if (isAllPermissionsGranted) {
        await videoService.initializeCamera();
        await audioService.fadeOutStop('bgm');
        return const Success(null);
      } else {
        return const Failure(
          'カメラ、マイク、フォトライブラリへのアクセスが全て許可されていません。\n'
          '動画を撮影するために設定から全てのアクセスを許可してください。',
        );
      }
    } catch (e) {
      return Failure(e.toString(), e as Exception?);
    }
  }
}
