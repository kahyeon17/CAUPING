import 'package:cauping/HomePage.dart';
import 'package:cauping/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:cauping/RegisterPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Colors.dart';
import 'ExplorePage.dart';
import 'FirstPage.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(
            color: CaupingBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  String email = " ";
  String password = " ";

  bool isButtonEnabled = false;

  // 모든 필드 유효성 검사
  void checkFormCompletion() {
    setState(() {
      isButtonEnabled = email.isNotEmpty &&
          password.isNotEmpty != null;
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
            Text('학교 이메일을 입력해주세요.',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
            const SizedBox(
              height: 8,
            ),
            TextField(
              //controller: nicknameController,
              onChanged: (value) {
                setState(() {
                  email = value;
                });
                _emailKey.currentState?.validate();
                checkFormCompletion();
              },
              decoration: const InputDecoration(
                hintText: 'cauping@cau.ac.kr',
                hintStyle: const TextStyle(
                  color: CaupingGray,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CaupingGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PrimaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text('비밀번호를 입력해주세요.',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
            const SizedBox(
              height: 8,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
                _passwordKey.currentState?.validate();
                checkFormCompletion();
              },
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '영문 대소문자와 숫자만 사용 가능합니다.',
                hintStyle: const TextStyle(
                  color: CaupingGray,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CaupingGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PrimaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
            ),
            SizedBox(
              height: 320,
            ),
            TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage(),),
                  );
                },
                child: Text('회원가입 하기',
                  style: TextStyle(
                    color: PrimaryColor,
                  ),)
            ),
            ElevatedButton(onPressed: () async {
              try{
                final currentUser =
                await _authentication.signInWithEmailAndPassword(
                    email: email, password: password);

                if (currentUser.user != null){
                  _formKey.currentState!.reset();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                        (route) => false, // 모든 기존 라우트를 제거
                  );
                }
              } catch (e){
                print(e);
              }
            },
              child: Text('완료',
                style: TextStyle(
                  color: Colors.white,
                ),),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isButtonEnabled ? PrimaryColor : CaupingGray, // 비활성화 상태에서 회색
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
