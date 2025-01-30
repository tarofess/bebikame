import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/application/usecase/save_video_usecase.dart';

final saveVideoUsecaseProvider = Provider((ref) => SaveVideoUsecase());
