class PuzzleRemoteConfig {
  // Buraya benim repo baz yolumu koy:
  // Örn: https://burakturk152.github.io/sikoku_puzzles/puzzles
  static const baseUrl = String.fromEnvironment(
    'PUZZLE_CDN_BASE',
    defaultValue: 'https://burakturk152.github.io/sikoku_puzzles/puzzles',
  );

  static const dailyPath = 'daily';
  static const weeklyPath = 'weekly';
  static const connectTimeout = Duration(seconds: 12);
  static const readTimeout = Duration(seconds: 15);
  static const dailyTtl = Duration(hours: 24);
  static const weeklyTtl = Duration(days: 7);
}
