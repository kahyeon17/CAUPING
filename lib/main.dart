import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cauping',
      theme: ThemeData(
        primaryColor: PrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: PrimaryColor),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: PrimaryColor,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 둥근 모서리 스타일
            ),
          ),
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const MyHomePage();
            }
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  get result => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Image.asset(
                'assets/images/logo.jpg', // 로고 이미지 경로 설정
                width: 300,
                height: 150,
              ),
            ),
            const SizedBox(height: 270),
            // 회원가입 버튼
            Container(
              width: 330,
              height: 45,
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SecondaryColor, // 연한 파란색 배경
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    color: PrimaryColor, // 진한 파란색 텍스트
                  ),
                ),
              ),
            ),
            // 로그인 버튼
            Container(
              width: 330,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Loginpage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryColor, // 진한 파란색 배경
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.white, // 흰색 텍스트
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
