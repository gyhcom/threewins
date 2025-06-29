import 'package:threewins/models/win.dart';

/// 하루의 승리 기록을 나타내는 모델 클래스입니다.
class DayRecord {
  /// 하루 기록의 고유 ID입니다.
  final String id;
  
  /// 기록된 날짜입니다.
  final DateTime date;
  
  /// 해당 날짜의 승리 항목 목록입니다.
  final List<Win> wins;
  
  /// 하루 기록을 생성합니다.
  DayRecord({
    required this.id,
    required this.date,
    required this.wins,
  });
  
  /// 완료된 승리 항목의 개수를 반환합니다.
  int get completedCount => wins.where((win) => win.isCompleted).length;
  
  /// 모든 승리 항목이 완료되었는지 확인합니다.
  bool get isFullyCompleted => completedCount == wins.length && wins.isNotEmpty;
  
  /// 일부 승리 항목만 완료되었는지 확인합니다.
  bool get isPartiallyCompleted => completedCount > 0 && completedCount < wins.length;
  
  /// Map에서 DayRecord 객체를 생성합니다.
  factory DayRecord.fromJson(Map<String, dynamic> json) {
    final List<dynamic> winsJson = json['wins'] as List<dynamic>;
    final List<Win> wins = winsJson
        .map((winJson) => Win.fromJson(winJson as Map<String, dynamic>))
        .toList();
    
    return DayRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      wins: wins,
    );
  }
  
  /// DayRecord 객체를 Map으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'wins': wins.map((win) => win.toJson()).toList(),
    };
  }
  
  /// DayRecord 객체의 복사본을 생성합니다.
  DayRecord copyWith({
    String? id,
    DateTime? date,
    List<Win>? wins,
  }) {
    return DayRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      wins: wins ?? this.wins,
    );
  }
  
  @override
  String toString() {
    return 'DayRecord{id: $id, date: $date, wins: $wins}';
  }
} 