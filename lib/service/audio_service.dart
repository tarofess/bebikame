import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final Map<String, AudioPlayer> _audioPlayers = {};

  AudioService();

  Future<void> loadAudio(String fileName) async {
    if (!_audioPlayers.containsKey(fileName)) {
      try {
        final player = AudioPlayer();
        await player.setSource(AssetSource('sounds/$fileName.mp3'));
        _audioPlayers[fileName] = player;
      } catch (e) {
        throw Exception('音声の読み込み中にエラーが発生しました。');
      }
    }
  }

  Future<void> play(String fileName,
      {bool loop = false, double volume = 1.0}) async {
    if (!_audioPlayers.containsKey(fileName)) {
      await loadAudio(fileName);
    }
    try {
      final player = _audioPlayers[fileName]!;
      player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      player.setPlayerMode(PlayerMode.lowLatency);
      player.setVolume(volume);
      await player.resume();
    } catch (e) {
      throw Exception('音声の再生中にエラーが発生しました。');
    }
  }

  Future<void> stop(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.stop();
      }
    } catch (e) {
      throw Exception('音声の停止中にエラーが発生しました。');
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
      throw Exception('音声のフェードアウト停止中にエラーが発生しました。');
    }
  }

  Future<void> pause(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.pause();
      }
    } catch (e) {
      throw Exception('音声の一時停止中にエラーが発生しました。');
    }
  }

  Future<void> resume(String fileName) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.resume();
      }
    } catch (e) {
      throw Exception('音声の再開中にエラーが発生しました。');
    }
  }

  Future<void> setVolume(String fileName, double volume) async {
    try {
      if (_audioPlayers.containsKey(fileName)) {
        await _audioPlayers[fileName]!.setVolume(volume);
      }
    } catch (e) {
      throw Exception('音量の設定中にエラーが発生しました。');
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
