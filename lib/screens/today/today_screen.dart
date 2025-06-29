import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/models/day_record.dart';
import 'package:threewins/models/quote.dart';
import 'package:threewins/models/win.dart';
import 'package:threewins/screens/today/components/daily_quote.dart';
import 'package:threewins/screens/today/components/progress_summary.dart';
import 'package:threewins/screens/today/components/win_item.dart';
import 'package:threewins/services/quote_service.dart';
import 'package:threewins/services/storage_service.dart';
import 'package:threewins/utils/date_utils.dart' as app_date_utils;
import 'package:threewins/widgets/app_bar.dart';
import 'package:threewins/widgets/loading_indicator.dart';

/// 오늘의 승리를 관리하는 화면입니다.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  /// 로딩 상태
  bool _isLoading = true;
  
  /// 오늘의 기록
  late DayRecord _todayRecord;
  
  /// 오늘의 명언
  late Quote _todayQuote;
  
  /// 스토리지 서비스
  final StorageService _storageService = StorageService();
  
  /// 명언 서비스
  final QuoteService _quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  /// 오늘의 데이터를 로드합니다.
  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 오늘 날짜의 기록 로드
      final String todayKey = app_date_utils.DateUtils.formatDateForStorage(DateTime.now());
      final DayRecord? record = await _storageService.getDayRecord(todayKey);
      
      if (record != null) {
        _todayRecord = record;
      } else {
        // 기록이 없으면 새로 생성
        final now = DateTime.now();
        _todayRecord = DayRecord(
          id: todayKey,
          date: now,
          wins: List.generate(3, (index) => Win(
            id: 'win_$index',
            text: '',
            isCompleted: false,
            createdAt: now,
          )),
        );
        
        // 새 기록 저장
        await _storageService.saveDayRecord(todayKey, _todayRecord);
      }

      // 오늘의 명언 로드
      _todayQuote = await _quoteService.getRandomQuote();
    } catch (e) {
      // 오류 발생 시 기본 데이터 사용
      final String todayKey = app_date_utils.DateUtils.formatDateForStorage(DateTime.now());
      final now = DateTime.now();
      _todayRecord = DayRecord(
        id: todayKey,
        date: now,
        wins: List.generate(3, (index) => Win(
          id: 'win_$index',
          text: '',
          isCompleted: false,
          createdAt: now,
        )),
      );
      
      _todayQuote = Quote(
        id: 'default',
        text: '시작이 반이다.',
        author: '아리스토텔레스',
      );
      
      // 오류 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터 로드 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 승리 항목 텍스트 변경 처리
  Future<void> _handleWinTextChanged(int index, String text) async {
    setState(() {
      _todayRecord.wins[index].text = text;
    });
    
    await _saveRecord();
  }

  /// 승리 항목 완료 상태 변경 처리
  Future<void> _handleWinCompletedChanged(int index, bool isCompleted) async {
    setState(() {
      _todayRecord.wins[index].isCompleted = isCompleted;
    });
    
    await _saveRecord();
  }

  /// 현재 기록을 저장합니다.
  Future<void> _saveRecord() async {
    final String todayKey = app_date_utils.DateUtils.formatDateForStorage(DateTime.now());
    await _storageService.saveDayRecord(todayKey, _todayRecord);
  }

  /// 완료된 승리 개수를 계산합니다.
  int _getCompletedCount() {
    return _todayRecord.wins.where((win) => win.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: '오늘의 할일',
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodayData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘 날짜 표시
              Text(
                app_date_utils.DateUtils.formatDateForDisplay(DateTime.now()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // 진행 상황 요약
              ProgressSummary(
                completedCount: _getCompletedCount(),
                totalCount: _todayRecord.wins.length,
              ),
              const SizedBox(height: 24),
              
              // 승리 항목 목록
              const Text(
                '오늘의 3가지 승리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _todayRecord.wins.length,
                (index) => WinItem(
                  win: _todayRecord.wins[index],
                  index: index,
                  onTextChanged: (text) => _handleWinTextChanged(index, text),
                  onCompletedChanged: (isCompleted) => 
                      _handleWinCompletedChanged(index, isCompleted),
                ),
              ),
              const SizedBox(height: 24),
              
              // 오늘의 명언
              DailyQuote(quote: _todayQuote),
            ],
          ),
        ),
      ),
    );
  }
} 