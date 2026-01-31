import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playNote(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  void dispose() {
    _player.dispose();
  }
}
