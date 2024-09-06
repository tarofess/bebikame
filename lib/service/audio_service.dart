import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final Map<String, AudioPlayer> _audioPlayers = {};

  AudioService();

  Future<void> loadAudio(String fileName) async {
    if (!_audioPlayers.containsKey(fileName)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource('sounds/$fileName.mp3'));
      _audioPlayers[fileName] = player;
    }
  }

  Future<void> play(String fileName,
      {bool loop = false, double volume = 1.0}) async {
    if (!_audioPlayers.containsKey(fileName)) {
      await loadAudio(fileName);
    }
    final player = _audioPlayers[fileName]!;
    player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    player.setPlayerMode(PlayerMode.lowLatency);
    player.setVolume(volume);
    await player.resume();
  }

  Future<void> stop(String fileName) async {
    if (_audioPlayers.containsKey(fileName)) {
      await _audioPlayers[fileName]!.stop();
    }
  }

  Future<void> pause(String fileName) async {
    if (_audioPlayers.containsKey(fileName)) {
      await _audioPlayers[fileName]!.pause();
    }
  }

  Future<void> resume(String fileName) async {
    if (_audioPlayers.containsKey(fileName)) {
      await _audioPlayers[fileName]!.resume();
    }
  }

  void dispose() {
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
  }
}
