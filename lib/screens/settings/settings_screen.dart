import 'package:flutter/material.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/services/quote_service.dart';
import 'package:threewins/services/storage_service.dart';
import 'package:threewins/widgets/app_bar.dart';
import 'package:threewins/widgets/loading_indicator.dart';

/// 설정 화면 클래스입니다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// 로딩 상태
  bool _isLoading = true;
  
  /// 명언 표시 여부
  bool _quoteEnabled = true;
  
  /// 알림 활성화 여부
  bool _notificationEnabled = false;
  
  /// 알림 시간
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  
  /// 다크 모드 여부
  bool _darkMode = false;
  
  /// 스토리지 서비스
  final StorageService _storageService = StorageService();
  
  /// 명언 서비스
  final QuoteService _quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 설정을 로드합니다.
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 설정 로드
      final quoteEnabled = await _storageService.getQuoteEnabled();
      final notificationEnabled = await _storageService.getNotificationEnabled();
      final notificationTimeString = await _storageService.getNotificationTime();
      final darkMode = await _storageService.getDarkMode();
      
      // 알림 시간 파싱
      final timeParts = notificationTimeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      setState(() {
        _quoteEnabled = quoteEnabled;
        _notificationEnabled = notificationEnabled;
        _notificationTime = TimeOfDay(hour: hour, minute: minute);
        _darkMode = darkMode;
      });
    } catch (e) {
      // 오류 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 로드 중 오류가 발생했습니다.')),
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

  /// 명언 표시 설정을 변경합니다.
  Future<void> _toggleQuoteEnabled(bool value) async {
    setState(() {
      _quoteEnabled = value;
    });
    
    await _quoteService.setQuoteEnabled(value);
  }

  /// 알림 활성화 설정을 변경합니다.
  Future<void> _toggleNotificationEnabled(bool value) async {
    setState(() {
      _notificationEnabled = value;
    });
    
    await _storageService.setNotificationEnabled(value);
  }

  /// 알림 시간을 변경합니다.
  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await _storageService.setNotificationTime(timeString);
    }
  }

  /// 다크 모드 설정을 변경합니다.
  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });
    
    await _storageService.setDarkMode(value);
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
        title: '설정',
      ),
      body: ListView(
        children: [
          // 앱 설정 섹션
          _buildSectionHeader('앱 설정'),
          
          // 명언 표시 설정
          _buildSwitchTile(
            title: '명언 표시',
            subtitle: '오늘의 명언을 표시합니다.',
            value: _quoteEnabled,
            onChanged: _toggleQuoteEnabled,
          ),
          
          // 다크 모드 설정
          _buildSwitchTile(
            title: '다크 모드',
            subtitle: '어두운 테마를 사용합니다.',
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          
          // 알림 설정 섹션
          _buildSectionHeader('알림 설정'),
          
          // 알림 활성화 설정
          _buildSwitchTile(
            title: '알림 활성화',
            subtitle: '매일 승리를 기록하도록 알림을 받습니다.',
            value: _notificationEnabled,
            onChanged: _toggleNotificationEnabled,
          ),
          
          // 알림 시간 설정
          ListTile(
            title: const Text(
              '알림 시간',
              style: TextStyle(color: AppTheme.textColor),
            ),
            subtitle: Text(
              '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: AppTheme.textColor.withOpacity(0.7)),
            ),
            trailing: const Icon(
              Icons.access_time,
              color: AppTheme.secondaryColor,
            ),
            enabled: _notificationEnabled,
            onTap: _notificationEnabled ? _selectNotificationTime : null,
          ),
          
          // 앱 정보 섹션
          _buildSectionHeader('앱 정보'),
          
          // 앱 버전
          ListTile(
            title: const Text(
              '앱 버전',
              style: TextStyle(color: AppTheme.textColor),
            ),
            subtitle: const Text(
              '1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          
          // 개발자 정보
          const ListTile(
            title: Text(
              '개발자',
              style: TextStyle(color: AppTheme.textColor),
            ),
            subtitle: Text(
              '쓰리윈스 팀',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          
          // 라이센스
          ListTile(
            title: const Text(
              '라이센스',
              style: TextStyle(color: AppTheme.textColor),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.secondaryColor,
              size: 16,
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName: '쓰리윈스',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2023 쓰리윈스 팀',
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더를 생성합니다.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  /// 스위치 타일을 생성합니다.
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.textColor.withOpacity(0.7)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentColor,
      inactiveThumbColor: Colors.grey,
    );
  }
} 