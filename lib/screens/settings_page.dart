/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // 로그인 페이지 import 필요

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('설정 페이지입니다.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // 로그아웃
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false, // 모든 이전 화면 제거
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('로그아웃', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int expiryNotificationDays = 7;

  @override
  void initState() {
    super.initState();
    _loadExpiryNotificationDays();
  }

  Future<void> _loadExpiryNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      expiryNotificationDays = prefs.getInt('expiryNotificationDays') ?? 7;
    });
  }

  Future<void> _saveExpiryNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('expiryNotificationDays', expiryNotificationDays);
  }

  void _incrementDays() {
    setState(() {
      expiryNotificationDays++;
    });
    _saveExpiryNotificationDays();
  }

  void _decrementDays() {
    if (expiryNotificationDays > 1) {
      setState(() {
        expiryNotificationDays--;
      });
      _saveExpiryNotificationDays();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 유통기한 알림 기간 설정 UI
            Text('유통기한 임박 알림 기간 (일)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementDays,
                  icon: Icon(Icons.remove_circle_outline, size: 30),
                ),
                SizedBox(width: 20),
                Text('$expiryNotificationDays', style: TextStyle(fontSize: 24)),
                SizedBox(width: 20),
                IconButton(
                  onPressed: _incrementDays,
                  icon: Icon(Icons.add_circle_outline, size: 30),
                ),
              ],
            ),
            SizedBox(height: 40),

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('로그아웃', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
