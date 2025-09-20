class GitHubPuzzleConfig {
  // Public repo (değiştirilebilir)
  static const owner = String.fromEnvironment('GH_OWNER', defaultValue: 'burakturk152');
  static const repo = String.fromEnvironment('GH_REPO', defaultValue: 'sikoku_puzzles');
  static const branch = String.fromEnvironment('GH_BRANCH', defaultValue: 'main');

  // Yol kökleri
  static const dailyDir = 'puzzles/daily';
  static const weeklyDir = 'puzzles/weekly';

  // Zaman aşımı ve TTL'ler
  static const connectTimeoutSec = 12;
  static const readTimeoutSec = 15;
  static const dailyTtlHours = 24; // cache kullanım süresi (hard stop değil; ETag varsa daha iyi)
  static const weeklyTtlDays = 7;

  // Rate limit notu: Public isteklerde 60 req/saat. Biz açılışta en fazla 2–3 istek yapacağız.
}
