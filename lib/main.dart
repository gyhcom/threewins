import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threewins/config/theme.dart';
import 'package:threewins/screens/calendar/calendar_screen.dart';
import 'package:threewins/screens/history/history_screen.dart';
import 'package:threewins/screens/settings/settings_screen.dart';
import 'package:threewins/screens/today/today_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  // 세로 모드만 지원
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 한국어 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);
  
  runApp(const ThreeWinsApp());
}

/// 쓰리윈스 앱의 메인 클래스입니다.
class ThreeWinsApp extends StatelessWidget {
  const ThreeWinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '쓰리윈스',
      theme: AppTheme.theme,
      darkTheme: AppTheme.theme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// 앱의 홈 페이지입니다.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 현재 선택된 탭 인덱스
  int _selectedIndex = 0;
  
  /// 탭에 해당하는 화면 목록
  final List<Widget> _screens = [
    const TodayScreen(),
    const CalendarScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];
  
  /// 바텀 네비게이션 바 아이템 목록
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.today),
      label: '오늘',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: '캘린더',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: '기록',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '설정',
    ),
  ];

  /// 탭 선택 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
