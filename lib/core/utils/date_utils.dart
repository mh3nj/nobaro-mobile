class DateHelper {
  static String today() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  static String nowTime() {
    final now = DateTime.now();
    return '${_pad(now.hour)}:${_pad(now.minute)}';
  }

  static String yesterday() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  static String lastYearDate() {
    final d = DateTime.now();
    try {
      final ly = DateTime(d.year - 1, d.month, d.day);
      return '${ly.year}-${_pad(ly.month)}-${_pad(ly.day)}';
    } catch (_) {
      final ly = DateTime(d.year - 1, d.month, 28);
      return '${ly.year}-${_pad(ly.month)}-${_pad(ly.day)}';
    }
  }

  static String friendlyDate(String dateStr) {
    if (dateStr == today()) return 'Today';
    if (dateStr == yesterday()) return 'Yesterday';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    final y = parts[0];
    if (m < 1 || m > 12) return dateStr;
    return '${months[m]} $d, $y';
  }

  static String monthName(int m) {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }

  static String shortMonth(int m) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }

  static int daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 1).difference(DateTime(year, 12, 1)).inDays;
    }
    return DateTime(year, month + 1, 1).difference(DateTime(year, month, 1)).inDays;
  }

  static int dayOfWeekIso(int year, int month, int day) {
    return DateTime(year, month, day).weekday - 1;
  }

  static int calculateStreak(List<String> normalDates) {
    if (normalDates.isEmpty) return 0;
    final dateSet = normalDates.toSet();
    int streak = 0;
    DateTime check = DateTime.now();
    while (true) {
      final ds = '${check.year}-${_pad(check.month)}-${_pad(check.day)}';
      if (dateSet.contains(ds)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
      if (streak > 3650) break;
    }
    return streak;
  }

  static List<String> getGapDates(List<String> normalDates, {int maxGaps = 90}) {
    if (normalDates.isEmpty) return [];
    normalDates.sort();
    final earliest = normalDates.first;
    final yesterdayD = DateTime.now().subtract(const Duration(days: 1));
    final gaps = <String>[];
    var cur = DateTime.parse(earliest);
    while (cur.isBefore(yesterdayD) || cur.isAtSameMomentAs(yesterdayD)) {
      final ds = '${cur.year}-${_pad(cur.month)}-${_pad(cur.day)}';
      if (!normalDates.contains(ds)) {
        gaps.add(ds);
        if (gaps.length >= maxGaps) break;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return gaps;
  }

  static String daysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
