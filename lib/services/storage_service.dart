import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threewins/config/constants.dart';
import 'package:threewins/models/day_record.dart';
import 'package:threewins/models/win.dart';
import 'package:threewins/utils/date_utils.dart' as app_date_utils;
import 'package:threewins/models/quote.dart';

/// 로컬 저장소 서비스 클래스입니다.
class StorageService {
  /// SharedPreferences 인스턴스입니다.
  SharedPreferences? _prefs;
  
  /// 서비스가 초기화되었는지 여부입니다.
  bool _isInitialized = false;
  
  /// SharedPreferences 키: 일일 승리 기록
  static const String _keyWinsPrefix = 'wins_';
  
  /// SharedPreferences 키: 일일 기록
  static const String _keyDayRecordPrefix = 'day_record_';
  
  /// SharedPreferences 키: 명언 활성화 여부
  static const String _keyQuoteEnabled = 'quote_enabled';
  
  /// SharedPreferences 키: 알림 활성화 여부
  static const String _keyNotificationEnabled = 'notification_enabled';
  
  /// SharedPreferences 키: 알림 시간
  static const String _keyNotificationTime = 'notification_time';
  
  /// SharedPreferences 키: 다크 모드 여부
  static const String _keyDarkMode = 'dark_mode';
  
  /// 로컬 저장소 서비스를 초기화합니다.
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }
  
  /// 오늘의 승리를 저장합니다.
  Future<void> saveWins(List<Win> wins) async {
    await init();
    final today = DateTime.now();
    final dateKey = app_date_utils.DateUtils.formatDateForStorage(today);
    final winsJson = wins.map((win) => win.toJson()).toList();
    await _prefs?.setString('$_keyWinsPrefix$dateKey', jsonEncode(winsJson));
  }
  
  /// 특정 날짜의 승리를 가져옵니다.
  Future<List<Win>> getWins(DateTime date) async {
    await init();
    final dateKey = app_date_utils.DateUtils.formatDateForStorage(date);
    final winsString = _prefs?.getString('$_keyWinsPrefix$dateKey');
    
    if (winsString == null) {
      return [];
    }
    
    try {
      final winsJson = jsonDecode(winsString) as List;
      return winsJson.map((json) => Win.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing wins: $e');
      return [];
    }
  }
  
  /// 일일 기록을 저장합니다.
  Future<void> saveDayRecord(String dateKey, DayRecord record) async {
    await init();
    final String key = '$_keyDayRecordPrefix$dateKey';
    final String recordJson = jsonEncode(record.toJson());
    await _prefs?.setString(key, recordJson);
  }
  
  /// 일일 기록을 가져옵니다.
  Future<DayRecord?> getDayRecord(String dateKey) async {
    await init();
    final String key = '$_keyDayRecordPrefix$dateKey';
    final String? recordJson = _prefs?.getString(key);
    
    if (recordJson == null) {
      return null;
    }
    
    return DayRecord.fromJson(jsonDecode(recordJson));
  }
  
  /// 모든 일일 기록의 키를 가져옵니다.
  Future<List<String>> getAllDayRecordKeys() async {
    await init();
    final allKeys = _prefs?.getKeys() ?? {};
    return allKeys
        .where((key) => key.startsWith(_keyDayRecordPrefix))
        .map((key) => key.substring(_keyDayRecordPrefix.length))
        .toList();
  }
  
  /// 모든 일일 기록을 가져옵니다.
  Future<List<DayRecord>> getAllDayRecords() async {
    final keys = await getAllDayRecordKeys();
    final List<DayRecord> records = [];
    
    for (final key in keys) {
      final record = await getDayRecord(key);
      if (record != null) {
        records.add(record);
      }
    }
    
    return records;
  }
  
  /// 명언 활성화 여부를 설정합니다.
  Future<void> setQuoteEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyQuoteEnabled, enabled);
  }
  
  /// 명언 활성화 여부를 가져옵니다.
  Future<bool> getQuoteEnabled() async {
    await init();
    return _prefs?.getBool(_keyQuoteEnabled) ?? true;
  }
  
  /// 알림 활성화 여부를 설정합니다.
  Future<void> setNotificationEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyNotificationEnabled, enabled);
  }
  
  /// 알림 활성화 여부를 가져옵니다.
  Future<bool> getNotificationEnabled() async {
    await init();
    return _prefs?.getBool(_keyNotificationEnabled) ?? false;
  }
  
  /// 알림 시간을 설정합니다.
  Future<void> setNotificationTime(String time) async {
    await init();
    await _prefs?.setString(_keyNotificationTime, time);
  }
  
  /// 알림 시간을 가져옵니다.
  Future<String> getNotificationTime() async {
    await init();
    return _prefs?.getString(_keyNotificationTime) ?? '09:00';
  }
  
  /// 다크 모드 여부를 설정합니다.
  Future<void> setDarkMode(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyDarkMode, enabled);
  }
  
  /// 다크 모드 여부를 가져옵니다.
  Future<bool> getDarkMode() async {
    await init();
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }
} 