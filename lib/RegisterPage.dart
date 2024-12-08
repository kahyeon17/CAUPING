import 'package:cauping/HomePage.dart';
import 'package:cauping/SuccessRegister.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: CaupingBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();

  String email = "";
  String password = "";
  String nickname = "";
  String? selectedDepartment;
  String feedbackMessage = '';

  bool isButtonEnabled = false;

  final List<String> departments = [
    '인문대학',
    '사회과학대학',
    '사범대학',
    '자연과학대학',
    '생명공학대학',
    '공과대학',
    '창의ICT공과대학',
    '소프트웨어대학',
    '경영경제대학',
    '의과대학',
    '약학대학',
    '적십자간호대학',
    '예술대학',
    '예술공학대학',
    '체육대학',
  ];

  // 모든 필드 유효성 검사
  void checkFormCompletion() {
    setState(() {
      isButtonEnabled = email.isNotEmpty &&
          password.isNotEmpty &&
          nickname.isNotEmpty &&
          selectedDepartment != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'STEP 1 계정 생성',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '학교 이메일을 입력해주세요.',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'cauping@cau.ac.kr',
                hintStyle: const TextStyle(
                  color: CaupingGray,
                  fontSize: 12,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: CaupingGray),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: PrimaryColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
                _emailKey.currentState?.validate();
                checkFormCompletion();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '중앙대학교 이메일을 입력해주세요.';
                } else if (!RegExp(r'^[\w-\.]+@cau\.ac\.kr$').hasMatch(value)) {
                  return '중앙대학교 이메일만 사용 가능합니다.';
                }
                return null; // 유효한 경우
              },
              key: _emailKey, // 개별 필드의 키
            ),
            const SizedBox(height: 15),
            Text(
              '비밀번호를 입력해주세요.',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호는 6글자 이상이어야 합니다.',
                hintStyle: const TextStyle(
                  color: CaupingGray,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
                _passwordKey.currentState?.validate();
                checkFormCompletion();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요.';
                } else if (value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다.';
                }
                return null;
              },
            ),
            const SizedBox(height: 35),
            Text(
              'STEP 2 프로필 등록',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '닉네임을 입력해주세요.',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                setState(() {
                  nickname = value;
                });
                checkFormCompletion();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CaupingGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PrimaryColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '소속대학을 선택해주세요.',
              style: TextStyle(
                color: CaupingBlack,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments
                  .map((department) => DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
                checkFormCompletion();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CaupingGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PrimaryColor),
                ),
              ),
            ),
            SizedBox(height: 69),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newUser =
                      await _authentication.createUserWithEmailAndPassword(
                          email: email, password: password);
                  if (newUser.user != null) {
                    // Firestore에 유저 데이터 저장
                    await _firestore
                        .collection('cauping01')
                        .doc(newUser.user!.uid)
                        .set({
                      'department': selectedDepartment ?? '',
                      'nickname': nickname,
                      'email': email,
                    });

                    _formKey.currentState!.reset();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SuccessRegister()),
                    );
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Text(
                '완료',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonEnabled
                    ? PrimaryColor
                    : CaupingGray, // 비활성화 상태에서 회색
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
