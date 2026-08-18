import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/models/player.dart';
import '../database/app_paths.dart';

class PlayerRepository {
  final AppPaths _paths = AppPaths();

  Future<Player> load() async {
    final base = await _paths.basePath;
    final file = File(p.join(base, 'player.json'));
    if (!await file.exists()) return Player();
    try {
      final content = await file.readAsString();
      return Player.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {
      return Player();
    }
  }

  Future<void> save(Player player) async {
    final base = await _paths.basePath;
    final file = File(p.join(base, 'player.json'));
    await file.writeAsString(jsonEncode(player.toJson()));
  }

  Future<bool> hasSeenOnboarding() async {
    final player = await load();
    return player.lastOpen.isNotEmpty;
  }

  Future<void> completeOnboarding() async {
    final player = await load();
    player.lastOpen = DateTime.now().toIso8601String().substring(0, 10);
    await save(player);
  }
}
