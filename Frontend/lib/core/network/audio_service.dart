import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Patrón Singleton para usar la misma instancia en toda la app
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  /// Inicia la música en bucle infinito
  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return; // Si ya está sonando, no hace nada
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/musica.mp3'));
      _isPlaying = true;
      _isMuted = false;
    } catch (e) {
      debugPrint('Error al reproducir audio global: $e');
    }
  }

  /// Pausa o reanuda la música (útil para el botón de volumen de las pantallas)
  void toggleMute() {
    if (_isMuted) {
      _audioPlayer.setVolume(1.0);
      _isMuted = false;
    } else {
      _audioPlayer.setVolume(0.0);
      _isMuted = true;
    }
  }

  /// Detiene la música por completo (por ejemplo, al llegar a los resultados finales)
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }
}