import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/models/day_record.dart';
import 'package:threewins/services/storage_service.dart';
import 'package:threewins/utils/date_utils.dart' as app_date_utils;
import 'package:threewins/widgets/app_bar.dart';
import 'package:threewins/widgets/loading_indicator.dart';

/// 기록 화면 클래스입니다.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// 로딩 상태
  bool _isLoading = true;
  
  /// 모든 기록 목록
  List<DayRecord> _records = [];
  
  /// 스토리지 서비스
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// 모든 기록을 로드합니다.
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 기록 로드
      final records = await _storageService.getAllDayRecords();
      
      // 날짜 내림차순 정렬 (최신순)
      records.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _records = records;
      });
    } catch (e) {
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

  /// 완료율을 계산합니다.
  double _calculateCompletionRate() {
    if (_records.isEmpty) {
      return 0.0;
    }
    
    int totalWins = 0;
    int completedWins = 0;
    
    for (final record in _records) {
      totalWins += record.wins.length;
      completedWins += record.completedCount;
    }
    
    return totalWins > 0 ? completedWins / totalWins : 0.0;
  }

  /// 최근 7일간의 완료율을 계산합니다.
  List<double> _calculateWeeklyCompletionRates() {
    final now = DateTime.now();
    final rates = <double>[];
    
    // 최근 7일에 대한 완료율 계산
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // 해당 날짜의 기록 찾기
      final record = _records.firstWhere(
        (r) => app_date_utils.DateUtils.isSameDay(r.date, normalizedDate),
        orElse: () => DayRecord(
          id: '',
          date: normalizedDate,
          wins: [],
        ),
      );
      
      // 완료율 계산
      final rate = record.wins.isEmpty 
          ? 0.0 
          : record.completedCount / record.wins.length;
      
      rates.add(rate);
    }
    
    return rates;
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

    final completionRate = _calculateCompletionRate();
    final weeklyRates = _calculateWeeklyCompletionRates();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: '승리 기록',
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _records.isEmpty
            ? const Center(
                child: Text(
                  '기록이 없습니다.\n오늘의 승리를 달성해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 전체 통계
                    _buildStatisticsCard(completionRate),
                    const SizedBox(height: 16),
                    
                    // 주간 통계
                    _buildWeeklyStatisticsCard(weeklyRates),
                    const SizedBox(height: 16),
                    
                    // 기록 목록
                    const Text(
                      '모든 기록',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 기록 목록 카드
                    ..._records.map((record) => _buildRecordCard(record)),
                  ],
                ),
              ),
      ),
    );
  }

  /// 전체 통계 카드를 생성합니다.
  Widget _buildStatisticsCard(double completionRate) {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '전체 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('총 기록 수', '${_records.length}일'),
                _buildStatItem(
                  '완료율',
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                ),
                _buildStatItem(
                  '연속 기록',
                  '${_calculateConsecutiveDays()}일',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(completionRate)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 주간 통계 카드를 생성합니다.
  Widget _buildWeeklyStatisticsCard(List<double> weeklyRates) {
    final now = DateTime.now();
    final weekdays = <String>[];
    
    // 최근 7일의 요일 약자 생성
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final weekday = _getWeekdayShort(date.weekday);
      weekdays.add(weekday);
    }

    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주간 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  7,
                  (index) => _buildBarChartItem(
                    weeklyRates[index],
                    weekdays[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 요일 약자를 반환합니다.
  String _getWeekdayShort(int weekday) {
    switch (weekday) {
      case 1: return '월';
      case 2: return '화';
      case 3: return '수';
      case 4: return '목';
      case 5: return '금';
      case 6: return '토';
      case 7: return '일';
      default: return '';
    }
  }

  /// 바 차트 아이템을 생성합니다.
  Widget _buildBarChartItem(double rate, String label) {
    final height = 100 * rate;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height > 0 ? height : 2,
          decoration: BoxDecoration(
            color: _getProgressColor(rate),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 통계 아이템을 생성합니다.
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  /// 기록 카드를 생성합니다.
  Widget _buildRecordCard(DayRecord record) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          app_date_utils.DateUtils.formatDateForDisplay(record.date),
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '완료: ${record.completedCount}/${record.wins.length}',
          style: TextStyle(
            color: record.isFullyCompleted
                ? Colors.green
                : record.isPartiallyCompleted
                    ? Colors.amber
                    : Colors.red,
          ),
        ),
        trailing: Icon(
          record.isFullyCompleted
              ? Icons.check_circle
              : record.isPartiallyCompleted
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
          color: record.isFullyCompleted
              ? Colors.green
              : record.isPartiallyCompleted
                  ? Colors.amber
                  : Colors.red,
        ),
        onTap: () => _showRecordDetails(record),
      ),
    );
  }

  /// 기록 상세 정보를 표시합니다.
  void _showRecordDetails(DayRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              app_date_utils.DateUtils.formatDateForDisplay(record.date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '완료: ${record.completedCount}/${record.wins.length}',
              style: TextStyle(
                fontSize: 16,
                color: record.isFullyCompleted
                    ? Colors.green
                    : record.isPartiallyCompleted
                        ? Colors.amber
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            ...record.wins.map((win) => _buildWinItem(win)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 승리 항목을 생성합니다.
  Widget _buildWinItem(win) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            win.isCompleted ? Icons.check_circle : Icons.cancel_outlined,
            color: win.isCompleted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              win.text.isEmpty ? '(내용 없음)' : win.text,
              style: TextStyle(
                color: AppTheme.textColor,
                decoration: win.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 진행률에 따른 색상을 반환합니다.
  Color _getProgressColor(double progress) {
    if (progress >= 1) {
      return Colors.green; // 모두 완료
    } else if (progress >= 0.7) {
      return Colors.lightGreen; // 70% 이상
    } else if (progress >= 0.3) {
      return Colors.amber; // 30% 이상
    } else {
      return Colors.redAccent; // 30% 미만
    }
  }

  /// 연속 기록 일수를 계산합니다.
  int _calculateConsecutiveDays() {
    if (_records.isEmpty) {
      return 0;
    }
    
    // 날짜순으로 정렬
    final sortedRecords = List<DayRecord>.from(_records);
    sortedRecords.sort((a, b) => a.date.compareTo(b.date));
    
    int consecutiveDays = 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 오늘 기록이 있는지 확인
    final hasTodayRecord = sortedRecords.any((record) => 
      app_date_utils.DateUtils.isSameDay(record.date, today));
    
    if (!hasTodayRecord) {
      return 0; // 오늘 기록이 없으면 연속 기록 0일
    }
    
    // 연속 기록 계산
    for (int i = 1; i < 100; i++) { // 최대 100일까지 확인
      final checkDate = today.subtract(Duration(days: i));
      final hasRecord = sortedRecords.any((record) => 
        app_date_utils.DateUtils.isSameDay(record.date, checkDate));
      
      if (hasRecord) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }
} 