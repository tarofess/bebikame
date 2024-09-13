import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'lib/config/env/.env')
abstract class Env {
  @EnviedField(varName: 'PRODUCT_ID')
  static const String product_id = _Env.product_id;
}
