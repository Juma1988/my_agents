import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/history_service.dart';
import 'screens/spin_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await HistoryService.init();
  runApp(const RestartWidget(child: MyApp()));
}

final bool isDebug = false;

/// Wraps the app and allows a full restart by rebuilding from scratch.
class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restart();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

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
