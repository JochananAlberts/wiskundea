import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('eval')
external JSAny jsEval(JSString script);

class SoundEngine {
  static final SoundEngine _instance = SoundEngine._internal();
  factory SoundEngine() => _instance;
  
  bool _initialized = false;
  bool isMuted = false;

  SoundEngine._internal() {
    if (kIsWeb) {
      _initWebAudio();
    }
  }

  void _initWebAudio() {
    try {
      if (!_initialized) {
        jsEval('''
          window._audioCtx = new (window.AudioContext || window.webkitAudioContext)();
          window._playSound = function(freq, type, duration, delay) {
            if (!window._audioCtx) return;
            const ctx = window._audioCtx;
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = type;
            osc.frequency.setValueAtTime(freq, ctx.currentTime + delay);
            
            osc.connect(gain);
            gain.connect(ctx.destination);
            
            gain.gain.setValueAtTime(0.1, ctx.currentTime + delay);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + duration);
            
            osc.start(ctx.currentTime + delay);
            osc.stop(ctx.currentTime + delay + duration);
          };
        '''.toJS);
        _initialized = true;
      }
    } catch (e) {
      debugPrint("Web Audio API not supported or error: $e");
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
  }

  void playFusionSound() {
    _play(600, 'sine', 0.1, 0);
    _play(800, 'sine', 0.3, 0.1);
  }

  void playErrorSound() {
    _play(150, 'sawtooth', 0.3, 0);
  }

  void playVictoryFanfare() {
    _play(440, 'square', 0.2, 0);
    _play(554, 'square', 0.2, 0.2);
    _play(659, 'square', 0.4, 0.4);
  }

  void playFlipSound() {
    _play(300, 'triangle', 0.1, 0);
    _play(150, 'triangle', 0.3, 0.1);
  }

  void playClickSound() {
    _play(800, 'sine', 0.05, 0);
  }

  void _play(double freq, String type, double duration, double delay) {
    if (isMuted || !kIsWeb || !_initialized) return;
    try {
      jsEval("if(window._playSound) window._playSound($freq, '$type', $duration, $delay);".toJS);
    } catch (e) {
      debugPrint("Sound error: $e");
    }
  }
}
