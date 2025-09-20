class WeeklyPuzzleSelection {
  static DateTime? _selectedMonday;

  static void set(DateTime monday) {
    _selectedMonday = DateTime(monday.year, monday.month, monday.day);
  }

  static DateTime? consume() {
    final val = _selectedMonday;
    _selectedMonday = null;
    return val;
  }
}


