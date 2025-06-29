import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';

/// 승리 달성 진행 상황을 표시하는 위젯입니다.
class ProgressSummary extends StatelessWidget {
  /// 완료된 승리 개수
  final int completedCount;
  
  /// 전체 승리 개수
  final int totalCount;

  const ProgressSummary({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercent = totalCount > 0 
        ? completedCount / totalCount 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 진행 상황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progressPercent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progressPercent)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressMessage(progressPercent),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withOpacity(0.8),
              fontStyle: FontStyle.italic,
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

  /// 진행률에 따른 메시지를 반환합니다.
  String _getProgressMessage(double progress) {
    if (progress >= 1) {
      return '축하합니다! 오늘의 모든 승리를 달성했습니다.';
    } else if (progress >= 0.7) {
      return '거의 다 왔습니다! 조금만 더 힘내세요.';
    } else if (progress >= 0.3) {
      return '좋은 진행 상황입니다. 계속 나아가세요.';
    } else if (progress > 0) {
      return '시작이 반입니다. 첫 승리를 축하합니다!';
    } else {
      return '오늘의 승리를 달성해보세요!';
    }
  }
} 