import 'package:cauping/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Colors.dart';
import 'SavedEvents.dart';
import 'UpdatedEvents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authentication = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 50,
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('cauping01')
                  .doc(_authentication.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    width: double.infinity, // 화면 너비에 맞추기
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: PrimaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['nickname']}님, 환영해요!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          data['department'] ?? '소속대학 정보 없음',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // 로딩 상태에서는 아무것도 표시하지 않음
                }
              },
            ),
            const SizedBox(height: 16.0),
            // 행사 저장 목록
            buildCustomRow('행사 저장 목록', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedEvents()),
              );
            }),
            // 행사 등록 목록
            buildCustomRow('행사 등록 목록', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpdatedEvents()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildCustomRow(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // 클릭 시 동작
      borderRadius: BorderRadius.circular(8.0), // Ripple 효과에 적용
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: SecondaryColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontFamily: 'Pretendard'),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16.0, color: CaupingGray),
          ],
        ),
      ),
    );
  }
}
