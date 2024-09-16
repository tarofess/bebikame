import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final Map<String, AudioPlayer> _audioPlayers = {};

  AudioService();

  Future<void> _loadAudio(String fileName) async {
    if (!_audioPlayers.containsKey(fileName)) {
      try {
        final player = AudioPlayer();
        await player.setSource(AssetSource('sounds/$fileName.mp3'));
        await player.setPlayerMode(PlayerMode.mediaPlayer);
        _audioPlayers[fileName] = player;
      } catch (e) {
        throw Exception('音声の読み込み中にエラーが発生しました。\n音声を再生できません。');
      }
    }
  }

  Future<void> play(String fileName,
      {bool loop = false, double volume = 1.0}) async {
    if (!_audioPlayers.containsKey(fileName)) {
      await _loadAudio(fileName);
    }
    try {
      _audioPlayers[fileName]!
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      _audioPlayers[fileName]!.setVolume(volume);
      await _audioPlayers[fileName]!.play(AssetSource('sounds/$fileName.mp3'));
    } catch (e) {
      throw Exception('音声の再生中にエラーが発生しました。\n音声を再生できません。');
    }
  }

  Future<void> stop(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.stop();
      }
    } catch (e) {
      throw Exception('音声の停止中にエラーが発生しました。\n音声を停止できません。');
    }
  }

  Future<void> fadeOutStop(String fileName,
      {Duration duration = const Duration(milliseconds: 500)}) async {
    if (!_audioPlayers.containsKey(fileName)) {
      return;
    }

    try {
      final player = _audioPlayers[fileName]!;
      final originalVolume = player.volume;
      const fadeSteps = 10;
      final stepDuration = duration ~/ fadeSteps;
      final volumeStep = originalVolume / fadeSteps;

      for (int i = fadeSteps - 1; i >= 0; i--) {
        await player.setVolume(volumeStep * i);
        await Future.delayed(stepDuration);
      }

      await player.pause();
      await player.setVolume(originalVolume);
    } catch (e) {
      throw Exception('音声の停止中にエラーが発生しました。\n音声を停止できません。');
    }
  }

  Future<void> fadeInStart(String fileName,
      {Duration duration = const Duration(milliseconds: 1000)}) async {
    if (!_audioPlayers.containsKey(fileName)) {
      await _loadAudio(fileName);
    }

    try {
      final player = _audioPlayers[fileName]!;
      const targetVolume = 0.3;
      const fadeSteps = 10;
      final stepDuration = duration ~/ fadeSteps;
      const volumeStep = targetVolume / fadeSteps;

      await player.setVolume(0);
      await player.resume();

      for (int i = 1; i <= fadeSteps; i++) {
        await player.setVolume(volumeStep * i);
        await Future.delayed(stepDuration);
      }

      await player.setVolume(targetVolume);
    } catch (e) {
      throw Exception('音声の開始中にエラーが発生しました。\n音声を再生できません。');
    }
  }

  Future<void> pause(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.pause();
      }
    } catch (e) {
      throw Exception('音声の一時停止中にエラーが発生しました。\n音声を停止できません。');
    }
  }

  Future<void> resume(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.resume();
      }
    } catch (e) {
      throw Exception('音声の再開中にエラーが発生しました。\n音声を再生できません。');
    }
  }

  Future<void> setVolume(String fileName, double volume) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.setVolume(volume);
      }
    } catch (e) {
      throw Exception('音量の設定中にエラーが発生しました。\n音量を設定できません。');
    }
  }

  void dispose() {
    try {
      for (var player in _audioPlayers.values) {
        player.dispose();
      }
      _audioPlayers.clear();
    } catch (e) {
      throw Exception('音声の破棄中にエラーが発生しました。');
    }
  }
}
