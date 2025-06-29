import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/models/day_record.dart';
import 'package:threewins/screens/today/components/win_item.dart';
import 'package:threewins/services/storage_service.dart';
import 'package:threewins/utils/date_utils.dart' as app_date_utils;
import 'package:threewins/widgets/app_bar.dart';
import 'package:threewins/widgets/loading_indicator.dart';

/// 캘린더 화면 클래스입니다.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// 로딩 상태
  bool _isLoading = true;
  
  /// 선택된 날짜
  DateTime _selectedDay = DateTime.now();
  
  /// 포커스된 날짜
  DateTime _focusedDay = DateTime.now();
  
  /// 기록이 있는 날짜 목록
  Map<DateTime, List<DayRecord>> _events = {};
  
  /// 선택된 날짜의 기록
  DayRecord? _selectedDayRecord;
  
  /// 스토리지 서비스
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  /// 캘린더 데이터를 로드합니다.
  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 기록 로드
      final records = await _storageService.getAllDayRecords();
      
      // 날짜별로 기록 정리
      final Map<DateTime, List<DayRecord>> events = {};
      for (final record in records) {
        final date = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(record);
      }
      
      setState(() {
        _events = events;
      });
      
      // 선택된 날짜의 기록 로드
      await _loadSelectedDayRecord();
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

  /// 선택된 날짜의 기록을 로드합니다.
  Future<void> _loadSelectedDayRecord() async {
    final dateKey = app_date_utils.DateUtils.formatDateForStorage(_selectedDay);
    final record = await _storageService.getDayRecord(dateKey);
    
    setState(() {
      _selectedDayRecord = record;
    });
  }

  /// 날짜 선택 처리
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    _loadSelectedDayRecord();
  }

  /// 날짜에 기록이 있는지 확인
  bool _hasRecordsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay]?.isNotEmpty ?? false;
  }

  /// 날짜의 완료 상태에 따른 마커 색상 반환
  Color _getMarkerColor(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final records = _events[normalizedDay];
    
    if (records == null || records.isEmpty) {
      return Colors.transparent;
    }
    
    final record = records.first;
    if (record.isFullyCompleted) {
      return Colors.green; // 모두 완료
    } else if (record.isPartiallyCompleted) {
      return Colors.amber; // 일부 완료
    } else {
      return Colors.red; // 미완료
    }
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
        title: '승리 캘린더',
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          Card(
            color: AppTheme.cardColor,
            margin: const EdgeInsets.all(8),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => app_date_utils.DateUtils.isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (!_hasRecordsForDay(date)) {
                    return null;
                  }
                  
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getMarkerColor(date),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 선택한 날짜의 승리 기록
          Expanded(
            child: _selectedDayRecord != null
              ? _buildDayRecordView()
              : Center(
                  child: Text(
                    '${app_date_utils.DateUtils.formatDateForDisplay(_selectedDay)}\n기록이 없습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// 선택한 날짜의 승리 기록 위젯을 생성합니다.
  Widget _buildDayRecordView() {
    if (_selectedDayRecord == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app_date_utils.DateUtils.formatDateForDisplay(_selectedDayRecord!.date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '완료: ${_selectedDayRecord!.completedCount}/${_selectedDayRecord!.wins.length}',
            style: TextStyle(
              fontSize: 16,
              color: _selectedDayRecord!.isFullyCompleted
                ? Colors.green
                : _selectedDayRecord!.isPartiallyCompleted
                  ? Colors.amber
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDayRecord!.wins.length,
              itemBuilder: (context, index) => WinItem(
                win: _selectedDayRecord!.wins[index],
                index: index,
                onTextChanged: (_) {}, // 읽기 전용이므로 변경 불가
                onCompletedChanged: (_) {}, // 읽기 전용이므로 변경 불가
                readOnly: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 