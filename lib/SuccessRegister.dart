import 'package:cauping/Colors.dart';
import 'package:cauping/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuccessRegister extends StatelessWidget {
  const SuccessRegister({super.key});

  Future<String> getNickname() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Firestore에서 닉네임 가져오기
      final doc = await FirebaseFirestore.instance
          .collection('cauping01') // Firestore 컬렉션 이름
          .doc(user.uid) // 현재 사용자 UID
          .get();

      return doc.data()?['nickname'] ?? '사용자'; // 닉네임 없으면 '사용자' 반환
    } else {
      return '사용자'; // 인증되지 않은 경우 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/images/horray.jpg', // 로고 이미지 경로 설정
                 width: 300,
                 height: 150,
            ),
              SizedBox(
                height: 50,
              ),
              FutureBuilder<String>(
                future: getNickname(), // 닉네임 가져오는 비동기 작업
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // 데이터가 성공적으로 로드된 경우만 처리
                    return Text(
                      '${snapshot.data}님, 환영해요!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CaupingBlack,
                      ),
                    );
                  } else {
                    // 데이터가 없거나 로딩 중이거나 에러가 발생한 경우 기본 빈 위젯 반환
                    return const SizedBox.shrink(); // 아무것도 표시하지 않음
                  }
                },
              ),
              Text('성공적으로 가입되었어요!',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CaupingBlack
              ),),
              SizedBox(
                height: 240,
              ),
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
      ),
    );
  }
}
