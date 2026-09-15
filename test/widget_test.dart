import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:risk_roulette/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('test_hive_dir');
    await Hive.openBox('settings');
    await Hive.openBox('history');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
