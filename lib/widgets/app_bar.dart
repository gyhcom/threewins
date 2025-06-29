import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';

/// 앱 전체에서 사용하는 커스텀 앱바입니다.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 앱바의 제목입니다.
  final String title;
  
  /// 앱바의 액션 버튼 목록입니다.
  final List<Widget>? actions;
  
  /// 뒤로가기 버튼을 표시할지 여부입니다.
  final bool showBackButton;
  
  /// 뒤로가기 버튼 클릭 시 실행할 함수입니다.
  final VoidCallback? onBackPressed;
  
  /// 앱바의 높이입니다.
  final double height;
  
  /// 커스텀 앱바를 생성합니다.
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: AppTheme.textColor),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 