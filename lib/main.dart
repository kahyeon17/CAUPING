import 'package:flutter/material.dart';
import 'package:cauping/EventRegisterPage.dart';
import 'package:cauping/ExploreScreen.dart';
import 'package:cauping/HomePage.dart';
import 'Colors.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 지도 초기화 상태 관리
  bool isNaverMapInitialized = false;

  // 네이버 지도 SDK 초기화ㅇ
  try {
    await NaverMapSdk.instance.initialize(
      clientId: '4jfm9e2by4', // 네이버 클라이언트 ID
      onAuthFailed: (error) {
        debugPrint("네이버맵 인증 오류: ${error.message}");
      },
    );
    isNaverMapInitialized = true; // 초기화 성공 시 true로 설정
  } catch (e) {
    debugPrint("네이버 지도 초기화 실패: $e");
  }

  runApp(MyApp(isNaverMapInitialized: isNaverMapInitialized));
}

class MyApp extends StatelessWidget {
  final bool isNaverMapInitialized;

  const MyApp({super.key, required this.isNaverMapInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: PrimaryColor),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: PrimaryColor,
          unselectedItemColor: Colors.grey,
        ),
        useMaterial3: true,
      ),
      home: MainScreen(isNaverMapInitialized: isNaverMapInitialized),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isNaverMapInitialized;

  const MainScreen({super.key, required this.isNaverMapInitialized});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    ExploreScreen(isNaverMapInitialized: widget.isNaverMapInitialized), // 탐색 화면
    const RegisterScreen(title: '행사 등록'), // 등록 화면
    const HomePage(), // 프로필 화면
  ];

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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            label: '탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
