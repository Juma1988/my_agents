import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:risk_roulette/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Use Hive directly (not initFlutter) to avoid path_provider in tests
    Hive.init('test_hive_dir');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
