import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class ThankyouSplash extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<ThankyouSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushNamedAndRemoveUntil(context, '/homeScreen', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'Assets/thankyou.json', // Replace with your Lottie animation path
          width: 350,
          height: 350,
          fit: BoxFit.contain,
          repeat: false
        ),
      ),
    );
  }
}
