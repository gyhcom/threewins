import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 상수 값들을 정의합니다.
class AppConstants {
  // 앱 이름
  static const String appName = 'Three Wins';
  
  // 로컬 저장소 키
  static const String keyWins = 'wins';
  static const String keySettings = 'settings';
  static const String keyQuoteEnabled = 'quote_enabled';
  
  // 최대 승리 개수
  static const int maxWins = 3;
  
  // 날짜 포맷
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'yyyy년 M월 d일';
  
  // 기본 응원 메시지 목록
  static const List<String> motivationalQuotes = [
    '오늘도 당신은 이길 수 있어요.',
    '작은 승리가 큰 변화를 만듭니다.',
    '하루에 세 가지 승리, 당신의 하루가 특별해집니다.',
    '지금 이 순간에 집중하세요.',
    '오늘의 작은 성취가 내일의 큰 성공을 만듭니다.',
    '실패는 없습니다. 오직 배움만 있을 뿐이죠.',
    '당신의 노력이 결실을 맺을 것입니다.',
    '오늘 하루도 승리의 발자취를 남기세요.',
    '작은 습관이 인생을 바꿉니다.',
    '매일의 작은 승리가 당신을 만듭니다.',
  ];
} 