import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/puzzle_remote_config.dart';

class RemotePuzzleProvider {
  final http.Client _client;
  RemotePuzzleProvider({http.Client? client}) : _client = client ?? http.Client();

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<File> _cacheFile(String subDir, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/puzzles/$subDir');
    if (!await d.exists()) await d.create(recursive: true);
    return File('${d.path}/$name');
  }

  Future<String?> _getWithCache({
    required Uri url,
    required File cache,
    required Duration ttl,
  }) async {
    if (await cache.exists()) {
      final age = DateTime.now().difference(await cache.lastModified());
      if (age <= ttl) {
        return cache.readAsString();
      }
    }
    try {
      final resp = await _client.get(url).timeout(
        PuzzleRemoteConfig.connectTimeout + PuzzleRemoteConfig.readTimeout,
      );
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        await cache.writeAsString(resp.body);
        return resp.body;
      }
    } catch (_) {
      // sessiz düş
    }
    if (await cache.exists()) return cache.readAsString();
    return null;
  }

  Future<String?> fetchDaily(DateTime localDate) async {
    final name = 'puzzle_${_fmt(localDate)}.json';
    final url = Uri.parse(
      '${PuzzleRemoteConfig.baseUrl}/${PuzzleRemoteConfig.dailyPath}/$name',
    );
    final cache = await _cacheFile('daily', name);
    return _getWithCache(url: url, cache: cache, ttl: PuzzleRemoteConfig.dailyTtl);
  }

  /// Haftalık: verilen tarihten haftanın PAZARTESİ'sini hesaplar.
  Future<String?> fetchWeekly(DateTime anyLocalDate) async {
    final monday = anyLocalDate.subtract(Duration(days: (anyLocalDate.weekday + 6) % 7));
    final name = 'puzzle_${_fmt(DateTime(monday.year, monday.month, monday.day))}.json';
    final url = Uri.parse(
      '${PuzzleRemoteConfig.baseUrl}/${PuzzleRemoteConfig.weeklyPath}/$name',
    );
    final cache = await _cacheFile('weekly', name);
    return _getWithCache(url: url, cache: cache, ttl: PuzzleRemoteConfig.weeklyTtl);
  }
}
