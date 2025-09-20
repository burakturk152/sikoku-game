class DailyPuzzleSelection {
  static DateTime? _selected;

  static void set(DateTime date) {
    _selected = DateTime(date.year, date.month, date.day);
  }

  static DateTime? consume() {
    final val = _selected;
    _selected = null;
    return val;
  }
}


