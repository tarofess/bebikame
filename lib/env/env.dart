import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'lib/env/.env')
abstract class Env {
  @EnviedField(varName: 'product_id_fireworks')
  static const String fireworksGame = _Env.fireworksGame;
  @EnviedField(varName: 'product_id_music')
  static const String musicGame = _Env.musicGame;
}
