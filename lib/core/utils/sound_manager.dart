// The QBasic soul of Nobaro: real square-wave beeps, synthesized on the
// fly and played through `audioplayers`. Every melody here mirrors
// assets/sounds.py in the Python app note-for-note (same frequencies,
// same durations, same little rests between phrases) so the mobile app
// sounds exactly like its desktop sibling.
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class _Tone {
  final int freq; // Hz. 0 means silence.
  final int ms;
  const _Tone(this.freq, this.ms);
}

class SoundManager {
  SoundManager._();

  static const int _sampleRate = 22050;
  static const double _amplitude = 0.42;

  /// Mirrors the Python `_note()` helper: each (freq, ms) pair gets a
  /// short 15ms rest after it by default.
  static List<_Tone> _seq(List<List<int>> notes, {int gap = 15}) {
    final out = <_Tone>[];
    for (final n in notes) {
      out.add(_Tone(n[0], n[1]));
      if (gap > 0) out.add(_Tone(0, gap));
    }
    return out;
  }

  // ---------------------------------------------------------------
  //  Melodies — kept in exact parity with assets/sounds.py
  // ---------------------------------------------------------------

  static List<_Tone> _startup() => [
        ..._seq([
          [262, 80],
          [330, 80],
          [392, 80],
          [523, 120],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [523, 60],
          [587, 60],
          [659, 180],
        ]),
        const _Tone(0, 80),
        ..._seq([
          [784, 80],
          [880, 300],
        ]),
      ];

  static List<_Tone> _quit() => _seq([
        [523, 80],
        [494, 80],
        [440, 80],
        [392, 80],
        [349, 80],
        [330, 80],
        [294, 80],
        [262, 300],
      ]);

  static List<_Tone> _save() => _seq([
        [660, 60],
        [880, 100],
      ]);

  static List<_Tone> _levelUp() => [
        ..._seq([
          [523, 80],
          [523, 80],
          [523, 80],
        ]),
        const _Tone(0, 40),
        ..._seq([
          [523, 80],
          [415, 80],
          [466, 80],
          [523, 200],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [466, 80],
          [523, 350],
        ]),
      ];

  static List<_Tone> _achievement() => [
        ..._seq([
          [659, 60],
          [784, 60],
          [1047, 120],
        ]),
        const _Tone(0, 40),
        ..._seq([
          [1047, 60],
          [1175, 200],
        ]),
      ];

  static List<_Tone> _seal() => [
        ..._seq([
          [440, 150],
          [415, 150],
          [370, 150],
          [330, 300],
        ]),
        const _Tone(0, 100),
        ..._seq([
          [220, 400],
        ]),
      ];

  static List<_Tone> _letterOpen() => [
        ..._seq([
          [330, 80],
          [392, 80],
        ]),
        const _Tone(0, 40),
        ..._seq([
          [523, 80],
          [659, 80],
          [784, 80],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [1047, 200],
        ]),
        const _Tone(0, 80),
        ..._seq([
          [784, 80],
          [1047, 80],
          [1175, 300],
        ]),
      ];

  static List<_Tone> _burn() => [
        ..._seq([
          [880, 80],
          [740, 80],
          [622, 80],
          [523, 80],
          [440, 80],
          [370, 80],
          [311, 80],
          [262, 80],
        ]),
        const _Tone(0, 30),
        ..._seq([
          [196, 400],
        ]),
      ];

  static List<_Tone> _sad() => [
        ..._seq([
          [330, 200],
          [311, 200],
          [294, 200],
        ]),
        const _Tone(0, 80),
        ..._seq([
          [277, 200],
          [262, 400],
        ]),
      ];

  static List<_Tone> _gorilla() => [
        ..._seq([
          [523, 100],
          [523, 100],
          [784, 100],
          [784, 100],
          [880, 200],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [784, 300],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [698, 100],
          [698, 100],
          [659, 100],
          [659, 100],
          [587, 200],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [523, 300],
        ]),
      ];

  static List<_Tone> _error() => _seq([
        [440, 80],
        [330, 80],
        [220, 200],
      ]);

  static List<_Tone> _notify() => [
        ..._seq([
          [880, 60],
        ]),
        const _Tone(0, 30),
        ..._seq([
          [1047, 100],
        ]),
      ];

  static List<_Tone> _attach() => _seq([
        [784, 60],
        [880, 60],
        [988, 80],
      ]);

  static List<_Tone> _streak(int days) {
    if (days >= 30) {
      return [
        ..._seq([
          [523, 60],
          [659, 60],
          [784, 60],
          [1047, 60],
          [1047, 60],
          [880, 60],
          [1047, 200],
        ]),
        const _Tone(0, 60),
        ..._seq([
          [1175, 400],
        ]),
      ];
    } else if (days >= 7) {
      return [
        ..._seq([
          [523, 80],
          [659, 80],
          [784, 200],
        ]),
        const _Tone(0, 40),
        ..._seq([
          [880, 300],
        ]),
      ];
    }
    return _seq([
      [659, 80],
      [784, 80],
      [880, 150],
    ]);
  }

  static List<_Tone> _passwordOk() => _seq([
        [440, 60],
        [660, 60],
        [880, 100],
      ]);

  static List<_Tone> _passwordFail() => _seq([
        [440, 80],
        [415, 80],
        [370, 150],
      ]);

  // ---------------------------------------------------------------
  //  Synthesis — pure-square PC-speaker-style tone, no assets needed
  // ---------------------------------------------------------------

  static Uint8List _synthesize(List<_Tone> tones) {
    int total = 0;
    final counts = <int>[];
    for (final t in tones) {
      final n = (_sampleRate * t.ms / 1000).round();
      counts.add(n);
      total += n;
    }
    final samples = Int16List(total);
    int offset = 0;
    for (int idx = 0; idx < tones.length; idx++) {
      final t = tones[idx];
      final n = counts[idx];
      if (t.freq > 0 && n > 0) {
        final period = _sampleRate / t.freq;
        final fade = math.min(n ~/ 6, (_sampleRate * 0.003).round()).clamp(1, n);
        for (int i = 0; i < n; i++) {
          final phase = (i % period) / period;
          double v = phase < 0.5 ? _amplitude : -_amplitude;
          if (i < fade) {
            v *= i / fade;
          } else if (i > n - fade) {
            v *= (n - i) / fade;
          }
          samples[offset + i] = (v * 32767).round().clamp(-32768, 32767);
        }
      }
      offset += n;
    }
    return _wavBytes(samples);
  }

  static Uint8List _wavBytes(Int16List samples) {
    final dataLength = samples.lengthInBytes;
    final b = ByteData(44 + dataLength);
    void str(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        b.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    b.setUint32(4, 36 + dataLength, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    b.setUint32(16, 16, Endian.little);
    b.setUint16(20, 1, Endian.little); // PCM
    b.setUint16(22, 1, Endian.little); // mono
    b.setUint32(24, _sampleRate, Endian.little);
    b.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
    b.setUint16(32, 2, Endian.little); // block align
    b.setUint16(34, 16, Endian.little); // bits per sample
    str(36, 'data');
    b.setUint32(40, dataLength, Endian.little);
    for (int i = 0; i < samples.length; i++) {
      b.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return b.buffer.asUint8List();
  }

  static void _play(List<_Tone> tones) {
    unawaited(_playAsync(tones));
  }

  static Future<void> _playAsync(List<_Tone> tones) async {
    try {
      final wav = _synthesize(tones);
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(BytesSource(wav, mimeType: 'audio/wav'));
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (_) {
      // Sound is a nice-to-have — never let it take the app down.
    }
  }

  // ---------------------------------------------------------------
  //  Public API — matches every play_* function in assets/sounds.py
  // ---------------------------------------------------------------

  static void playStartup() => _play(_startup());
  static void playQuit() => _play(_quit());
  static void playSave() => _play(_save());
  static void playLevelUp() => _play(_levelUp());
  static void playAchievement() => _play(_achievement());
  static void playSeal() => _play(_seal());
  static void playLetterOpen() => _play(_letterOpen());
  static void playBurn() => _play(_burn());
  static void playSad() => _play(_sad());
  static void playGorilla() => _play(_gorilla());
  static void playError() => _play(_error());
  static void playNotify() => _play(_notify());
  static void playAttach() => _play(_attach());
  static void playStreak(int days) => _play(_streak(days));
  static void playPasswordOk() => _play(_passwordOk());
  static void playPasswordFail() => _play(_passwordFail());
}
