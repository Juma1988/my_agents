import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/spin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const MyApp());
}

final bool isDebug = true;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Spin',
      debugShowCheckedModeBanner: isDebug,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF1A1A2E)),
      home: const SpinScreen(),
    );
  }
}
