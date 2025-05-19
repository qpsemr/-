/// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardapp/recipe_ai_test.dart';
import 'screens/fridge_page.dart';
import 'screens/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  runApp(MyApp());

}
/*void main() async {  // 레시피 ai 테스트 용
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); //  .env 초기화
  runApp(MaterialApp(home: GptTestPage()));
}*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/fridge': (context) => FridgePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중일 때
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // 로그인된 사용자라면
          return FridgePage();
        } else {
          // 로그인 안 되어있으면
          return LoginPage();
        }
      },
    );
  }
}