import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final _player = AudioPlayer();

  Future<void> playShutter() async {
    await _player.play(AssetSource('sounds/shutter.wav'));
  }

  Future<void> playSuccess() async {
    await _player.play(AssetSource('sounds/scan_success.wav'));
  }

  Future<void> playAlert() async {
    await _player.play(AssetSource('sounds/scan_alert.wav'));
  }

  void dispose() {
    _player.dispose();
  }
}
