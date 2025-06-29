import 'package:intl/intl.dart';
import 'package:threewins/config/constants.dart';

/// 날짜 관련 유틸리티 함수를 제공하는 클래스입니다.
class DateUtils {
  /// 현재 날짜의 문자열 표현을 반환합니다. (yyyy-MM-dd 형식)
  static String getTodayString() {
    return formatDate(DateTime.now());
  }
  
  /// 날짜를 문자열로 변환합니다. (yyyy-MM-dd 형식)
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  /// 날짜를 표시용 문자열로 변환합니다. (yyyy년 M월 d일 형식)
  static String formatDisplayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }
  
  /// 문자열을 DateTime으로 변환합니다. (yyyy-MM-dd 형식)
  static DateTime parseDate(String dateString) {
    return DateFormat(AppConstants.dateFormat).parse(dateString);
  }
  
  /// 날짜를 스토리지에 저장하기 위한 형식으로 변환합니다.
  /// 예: '2023-05-15'
  static String formatDateForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// 날짜를 화면에 표시하기 위한 형식으로 변환합니다.
  /// 예: '2023년 5월 15일 월요일'
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(date);
  }
  
  /// 두 날짜가 같은 날인지 확인합니다.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// 날짜가 오늘인지 확인합니다.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }
  
  /// 날짜가 어제인지 확인합니다.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  /// 날짜가 내일인지 확인합니다.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }
  
  /// 날짜가 이번 주인지 확인합니다.
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(firstDayOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(lastDayOfWeek.add(const Duration(days: 1)));
  }
  
  /// 날짜가 이번 달인지 확인합니다.
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  /// 주어진 날짜가 과거인지 확인합니다.
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }
  
  /// 주어진 날짜가 미래인지 확인합니다.
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }
  
  /// 한 달의 첫 날을 반환합니다.
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 한 달의 마지막 날을 반환합니다.
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
} 