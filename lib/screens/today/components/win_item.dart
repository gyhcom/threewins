import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/models/win.dart';

/// 승리 항목을 표시하는 위젯입니다.
class WinItem extends StatefulWidget {
  /// 승리 항목 모델
  final Win win;
  
  /// 승리 항목 인덱스
  final int index;
  
  /// 텍스트 변경 시 호출되는 콜백
  final Function(String) onTextChanged;
  
  /// 완료 상태 변경 시 호출되는 콜백
  final Function(bool) onCompletedChanged;
  
  /// 읽기 전용 모드 여부
  final bool readOnly;

  const WinItem({
    super.key,
    required this.win,
    required this.index,
    required this.onTextChanged,
    required this.onCompletedChanged,
    this.readOnly = false,
  });

  @override
  State<WinItem> createState() => _WinItemState();
}

class _WinItemState extends State<WinItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.win.text);
    _focusNode = FocusNode();
    
    // 포커스 변경 시 텍스트 저장
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onTextChanged(_controller.text);
      }
    });
  }
  
  @override
  void didUpdateWidget(WinItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트되면 컨트롤러 텍스트도 업데이트
    if (oldWidget.win.text != widget.win.text && _controller.text != widget.win.text) {
      _controller.text = widget.win.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 체크박스
            Checkbox(
              value: widget.win.isCompleted,
              onChanged: widget.readOnly 
                ? null 
                : (value) {
                    widget.onCompletedChanged(value ?? false);
                  },
              activeColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            // 승리 항목 번호
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.secondaryColor,
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 승리 항목 텍스트 필드
            Expanded(
              child: widget.readOnly
                ? Text(
                    widget.win.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.win.isCompleted 
                        ? AppTheme.textColor.withOpacity(0.7)
                        : AppTheme.textColor,
                      decoration: widget.win.isCompleted 
                        ? TextDecoration.lineThrough
                        : null,
                    ),
                  )
                : TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: true,
                    decoration: InputDecoration(
                      hintText: '승리 ${widget.index + 1} 입력',
                      hintStyle: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.win.isCompleted
                        ? AppTheme.textColor.withOpacity(0.7)
                        : AppTheme.textColor,
                      decoration: widget.win.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    ),
                    onChanged: (value) {
                      widget.onTextChanged(value);
                    },
                    onSubmitted: (value) {
                      widget.onTextChanged(value);
                    },
                    textInputAction: TextInputAction.done,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 