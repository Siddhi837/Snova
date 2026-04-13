import 'package:flutter/material.dart';
import 'package:snova/screens/authentication/login_screen.dart';
import 'package:snova/screens/home/home_page_activity.dart';
import 'package:snova/screens/utils/my_preference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 12), (){
      _navigateNext();
    });
  }

  void _navigateNext() async {

    bool isLogin = await MyPreference.getLogin();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLogin
            ? const HomePageActivity()
            : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F1),
      body: Center(
        child: Image.asset("assets/snova_logo.gif"),
      ),
    );
  }
}
