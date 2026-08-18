import 'dart:math';

class IdGenerator {
  static String generateNoteId() {
    final now = DateTime.now();
    final rand = Random().nextInt(0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
    final ts = '${now.year}${_pad(now.month)}${_pad(now.day)}-${_pad(now.hour)}${_pad(now.minute)}';
    return '$ts-$rand';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
