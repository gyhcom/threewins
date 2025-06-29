import 'dart:math';
import 'package:threewins/config/constants.dart';
import 'package:threewins/models/quote.dart';
import 'package:threewins/services/storage_service.dart';

/// 명언/응원 메시지 서비스 클래스입니다.
class QuoteService {
  /// 저장소 서비스 인스턴스입니다.
  final StorageService _storageService;
  
  /// 오늘의 명언/응원 메시지입니다.
  Quote? _todayQuote;
  
  /// 기본 명언 목록
  final List<Quote> _defaultQuotes = [
    Quote(
      id: '1',
      text: '작은 승리가 모여 큰 성공을 만든다.',
      author: '존 우든',
    ),
    Quote(
      id: '2',
      text: '시작이 반이다.',
      author: '아리스토텔레스',
    ),
    Quote(
      id: '3',
      text: '오늘 할 수 있는 일을 내일로 미루지 마라.',
      author: '벤자민 프랭클린',
    ),
    Quote(
      id: '4',
      text: '실패는 성공의 어머니다.',
      author: '토마스 에디슨',
    ),
    Quote(
      id: '5',
      text: '천 리 길도 한 걸음부터.',
      author: '노자',
    ),
    Quote(
      id: '6',
      text: '성공은 매일 반복한 작은 노력들의 합이다.',
      author: '로버트 콜리어',
    ),
    Quote(
      id: '7',
      text: '오늘 당신의 작은 승리를 축하하라.',
      author: '쓰리윈스',
    ),
  ];
  
  /// 명언/응원 메시지 서비스를 생성합니다.
  QuoteService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();
  
  /// 오늘의 명언/응원 메시지를 불러옵니다.
  Future<String?> getTodayQuote() async {
    // 응원 메시지 표시 설정을 확인합니다.
    final quoteEnabled = await _storageService.getQuoteEnabled();
    if (!quoteEnabled) return null;
    
    // 이미 오늘의 명언/응원 메시지가 있다면 반환합니다.
    if (_todayQuote != null) return _todayQuote!.text;
    
    // 랜덤으로 명언/응원 메시지를 선택합니다.
    final random = Random();
    final quotes = AppConstants.motivationalQuotes;
    final randomIndex = random.nextInt(quotes.length);
    
    _todayQuote = Quote(
      id: randomIndex.toString(),
      text: quotes[randomIndex],
    );
    
    return _todayQuote!.text;
  }
  
  /// 응원 메시지 표시 설정을 저장합니다.
  Future<void> setQuoteEnabled(bool enabled) async {
    await _storageService.setQuoteEnabled(enabled);
  }
  
  /// 응원 메시지 표시 설정을 불러옵니다.
  Future<bool> getQuoteEnabled() async {
    return _storageService.getQuoteEnabled();
  }

  /// 랜덤한 명언을 반환합니다.
  Future<Quote> getRandomQuote() async {
    // 실제 앱에서는 API 호출이나 로컬 DB에서 가져올 수 있음
    // 현재는 기본 목록에서 랜덤하게 선택
    final random = Random();
    final index = random.nextInt(_defaultQuotes.length);
    return _defaultQuotes[index];
  }

  /// 모든 명언을 반환합니다.
  Future<List<Quote>> getAllQuotes() async {
    // 실제 앱에서는 API 호출이나 로컬 DB에서 가져올 수 있음
    return _defaultQuotes;
  }
} 