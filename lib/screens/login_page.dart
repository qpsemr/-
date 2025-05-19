import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/fridge');
    } on FirebaseAuthException catch (e) {
      print('에러 코드: ${e.code}');

      String errorMessage = '로그인에 실패했습니다. 아이디 또는 비밀번호를 확인해주세요.';

      if (e.code == 'invalid-email') {
        errorMessage = '올바르지 않은 이메일 형식입니다.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = '아이디 또는 비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = '네트워크 오류가 발생했습니다. 인터넷 상태를 확인해주세요.';
      }

      _showErrorDialog('로그인 실패', errorMessage);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100], // 노란색 배경
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 아이디 입력
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: '아이디',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 비밀번호 입력
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: '비밀번호',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600], // 파란색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('로그인', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              SizedBox(height: 12),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 흰색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Text('회원가입', style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ),

              SizedBox(height: 20),

              // 아이디/비밀번호 찾기
              TextButton(
                onPressed: () {
                  // TODO: 아이디/비밀번호 찾기 기능 추가 가능
                },
                child: Text(
                  '아이디 / 비밀번호 찾기 >',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
