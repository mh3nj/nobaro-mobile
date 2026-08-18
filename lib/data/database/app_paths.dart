// Plain JSON file storage — no database engine involved. This is the
// single source of truth for where notes, media, backups, and exports
// live on disk, all under one Nobaro folder in the app's documents
// directory, mirroring the desktop app's flat-file layout.
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants.dart';

class AppPaths {
  static final AppPaths _instance = AppPaths._();
  factory AppPaths() => _instance;
  AppPaths._();

  String? _basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    final dir = await getApplicationDocumentsDirectory();
    _basePath = p.join(dir.path, AppConstants.dataDir);
    final d = Directory(_basePath!);
    if (!await d.exists()) await d.create(recursive: true);
    return _basePath!;
  }

  Future<String> notesPath() async {
    final dir = p.join(await basePath, AppConstants.notesDir);
    final d = Directory(dir);
    if (!await d.exists()) await d.create(recursive: true);
    return dir;
  }

  Future<String> mediaPath() async {
    final dir = p.join(await basePath, AppConstants.mediaDir);
    final d = Directory(dir);
    if (!await d.exists()) await d.create(recursive: true);
    return dir;
  }

  Future<String> backupsPath() async {
    final dir = p.join(await basePath, AppConstants.backupsDir);
    final d = Directory(dir);
    if (!await d.exists()) await d.create(recursive: true);
    return dir;
  }

  Future<String> exportsPath() async {
    final dir = p.join(await basePath, AppConstants.exportsDir);
    final d = Directory(dir);
    if (!await d.exists()) await d.create(recursive: true);
    return dir;
  }
}
