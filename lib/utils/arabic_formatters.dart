class ArabicFormatters {
  /// تحويل رقم الصف إلى مسمى نصي رسمي
  static String getGradeName(String rawGrade) {
    final clean = rawGrade.trim();
    switch (clean) {
      case '7':
      case 'السابع':
        return 'السابع';
      case '8':
      case 'الثامن':
        return 'الثامن';
      case '9':
      case 'التاسع':
        return 'التاسع';
      case '10':
      case 'العاشر':
        return 'العاشر';
      case '11':
      case 'الحادي عشر':
        return 'الحادي عشر';
      case '12':
      case 'الباكلوريا':
      case 'البكالوريا':
      case 'الثالث الثانوي':
        return 'الباكلوريا';
      default:
        return clean;
    }
  }

  /// حساب رقم المجلد ديناميكياً من السنة الحالية (2026 -> 26)
  static String getVolumeNumber() {
    return (DateTime.now().year % 100).toString();
  }

  /// الحصول على تاريخ اليوم الحالي بصيغة YYYY/MM/DD
  static String getCurrentFormattedDate() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }
}