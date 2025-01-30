import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';

@freezed
class Game with _$Game {
  const factory Game({
    required String name,
    required String image,
    required bool isLocked,
    @Default(false) bool selected,
  }) = _Game;
}
