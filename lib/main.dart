import 'package:echogreen/settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'firebase_options.dart';
import 'form_screen_1.dart';
import 'package:echogreen/resgister_completion.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();

  // Open a box (database)
  await Hive.openBox<Map>('sensor_data');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check SharedPreferences for "user" key
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString('user');

  runApp(MyApp(initialRoute: user != null ? '/homeScreen' : '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo Green',
      initialRoute: initialRoute,
      routes: {
        '/': (context) => FormScreen1(),
        '/thankyouSplash': (context) => ThankyouSplash(),
        '/homeScreen': (context) => HomeScreen(),
        '/settings' : (context) => SettingsPage(),
      },
    );
  }
}
