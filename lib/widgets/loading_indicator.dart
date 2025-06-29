import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';

/// 로딩 인디케이터 위젯입니다.
class LoadingIndicator extends StatelessWidget {
  /// 로딩 중임을 나타내는 메시지입니다.
  final String? message;
  
  /// 로딩 인디케이터의 색상입니다.
  final Color? color;
  
  /// 로딩 인디케이터의 크기입니다.
  final double size;
  
  /// 로딩 인디케이터의 두께입니다.
  final double strokeWidth;
  
  /// 로딩 인디케이터 위젯을 생성합니다.
  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? AppTheme.secondaryColor,
              strokeWidth: strokeWidth,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 