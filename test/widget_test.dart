import 'package:expense_income/app.dart';
import 'package:expense_income/presentation/state_holders/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use SQLite FFI so widget tests can run on the desktop test environment.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Keep preferences isolated between tests.
    SharedPreferences.setMockInitialValues({});

    // Reset GetX registrations before configuring this test.
    Get.reset();
    Get.testMode = true;

    // Register the theme controller if the app expects it to exist at startup.
    Get.put<ThemeController>(ThemeController());
    await Get.find<ThemeController>().loadThemeMode();
  });

  tearDown(() async {
    Get.reset();
    Get.testMode = false;
  });

  group('Expense & Income app startup', () {
    testWidgets('builds the app root and GetMaterialApp without exceptions',
            (WidgetTester tester) async {
          await tester.pumpWidget(const ExpenseIncome());

          // Allow initial synchronous and short asynchronous startup work to run.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 700));

          expect(find.byType(ExpenseIncome), findsOneWidget);
          expect(find.byType(GetMaterialApp), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });
}
