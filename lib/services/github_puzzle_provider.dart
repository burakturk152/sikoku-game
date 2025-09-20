import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/github_puzzle_config.dart';

class GitHubPuzzleProvider {
  final http.Client _client;
  
  GitHubPuzzleProvider({http.Client? client}) : _client = client ?? http.Client();

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<File> _cacheFile(String subDir, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/github_cache/$subDir');
    if (!await d.exists()) await d.create(recursive: true);
    return File('${d.path}/$name');
  }

  Future<File> _etagFile(String subDir, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/github_cache/$subDir');
    if (!await d.exists()) await d.create(recursive: true);
    return File('${d.path}/$name.etag');
  }

  Future<File> _timestampFile(String subDir, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/github_cache/$subDir');
    if (!await d.exists()) await d.create(recursive: true);
    return File('${d.path}/$name.timestamp');
  }

  Future<String?> _getWithETag({
    required Uri url,
    required File cache,
    required File etagFile,
    required File timestampFile,
    required Duration ttl,
  }) async {
    // Önce cache kontrolü (TTL)
    if (await cache.exists() && await timestampFile.exists()) {
      final timestamp = await timestampFile.readAsString();
      final lastSuccess = DateTime.tryParse(timestamp);
      if (lastSuccess != null) {
        final age = DateTime.now().difference(lastSuccess);
        if (age <= ttl) {
          return await cache.readAsString();
        }
      }
    }

    // ETag varsa If-None-Match header'ı ekle
    String? etag;
    if (await etagFile.exists()) {
      etag = await etagFile.readAsString();
    }

    try {
      final headers = <String, String>{};
      if (etag != null) {
        headers['If-None-Match'] = etag;
      }

      final response = await _client
          .get(url, headers: headers)
          .timeout(Duration(seconds: GitHubPuzzleConfig.connectTimeoutSec + GitHubPuzzleConfig.readTimeoutSec));

      if (response.statusCode == 200) {
        // Yeni içerik geldi, cache'e yaz
        await cache.writeAsString(response.body);
        await timestampFile.writeAsString(DateTime.now().toIso8601String());
        
        // ETag'i kaydet
        final responseETag = response.headers['etag'];
        if (responseETag != null) {
          await etagFile.writeAsString(responseETag);
        }
        
        return response.body;
      } else if (response.statusCode == 304) {
        // Değişiklik yok, cache'den oku
        if (await cache.exists()) {
          return await cache.readAsString();
        }
      } else if (response.statusCode == 404) {
        // Dosya bulunamadı
        return null;
      }
    } catch (e) {
      // Hata durumunda cache'den oku
      if (await cache.exists()) {
        return await cache.readAsString();
      }
    }

    return null;
  }

  Future<String?> fetchDaily(DateTime dateLocal) async {
    final name = 'puzzle_${_fmt(dateLocal)}.json';
    final url = Uri.parse(
      'https://raw.githubusercontent.com/${GitHubPuzzleConfig.owner}/${GitHubPuzzleConfig.repo}/${GitHubPuzzleConfig.branch}/${GitHubPuzzleConfig.dailyDir}/$name',
    );
    
    final cache = await _cacheFile('daily', name);
    final etagFile = await _etagFile('daily', name);
    final timestampFile = await _timestampFile('daily', name);
    
    return _getWithETag(
      url: url,
      cache: cache,
      etagFile: etagFile,
      timestampFile: timestampFile,
      ttl: Duration(hours: GitHubPuzzleConfig.dailyTtlHours),
    );
  }

  Future<String?> fetchWeekly(DateTime dateLocal) async {
    // Pazartesi'yi hesapla
    final monday = dateLocal.subtract(Duration(days: (dateLocal.weekday + 6) % 7));
    final name = 'puzzle_${_fmt(monday)}.json';
    final url = Uri.parse(
      'https://raw.githubusercontent.com/${GitHubPuzzleConfig.owner}/${GitHubPuzzleConfig.repo}/${GitHubPuzzleConfig.branch}/${GitHubPuzzleConfig.weeklyDir}/$name',
    );
    
    final cache = await _cacheFile('weekly', name);
    final etagFile = await _etagFile('weekly', name);
    final timestampFile = await _timestampFile('weekly', name);
    
    return _getWithETag(
      url: url,
      cache: cache,
      etagFile: etagFile,
      timestampFile: timestampFile,
      ttl: Duration(days: GitHubPuzzleConfig.weeklyTtlDays),
    );
  }

  // Cache'i temizle
  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/github_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Cache temizleme hatası: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
