import 'package:audioplayers/audioplayers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bgmManagerProvider = Provider((ref) => BgmManager());

class BgmManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  BgmManager() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setSource(AssetSource('sounds/bgm.mp3'));
    _audioPlayer.setVolume(0.3);
  }

  void play() {
    if (!_isPlaying) {
      _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  void stop() {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void pauseIfPlaying() {
    if (_isPlaying) {
      _audioPlayer.pause();
    }
  }

  void resumeIfPaused() {
    if (!_isPlaying) {
      _audioPlayer.resume();
      _isPlaying = true;
    }
  }
}
