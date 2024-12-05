import 'package:flutter/material.dart';
import 'package:cauping/EventRegisterPage.dart';
import 'package:cauping/ExploreScreen.dart';
import 'package:cauping/HomePage.dart';
import 'Colors.dart';

bool isNaverMapInitialized = false; // 네이버 지도 SDK 초기화 상태 관리

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 지도 초기화
  try {
    // 네이버 지도 SDK 초기화 코드 삽입 (예: NaverMapSdk.instance.initialize)
    isNaverMapInitialized = true; // 초기화 성공 시 true로 설정
  } catch (e) {
    debugPrint("네이버 지도 초기화 실패: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    ExploreScreen(isNaverMapInitialized: isNaverMapInitialized), // 탐색 화면
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
