import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/spin_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const MyApp());
}

final bool isDebug = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Spin',
      debugShowCheckedModeBanner: isDebug,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.background),
      home: const SpinScreen(),
    );
  }
}
