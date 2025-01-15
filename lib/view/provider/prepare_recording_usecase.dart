import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/application/usecase/prepare_recording_usecase.dart';

final prepareRecordingUsecaseProvider = Provider(
  (ref) => PrepareRecordingUsecase(),
);
