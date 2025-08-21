import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_tasks/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_tasks/provider/task_provider.dart';
import 'package:pocket_tasks/screen/home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskProvider search + filter', () {
    late TaskProvider tp;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tp = TaskProvider();
      await Future<void>.delayed(Duration.zero);

      await tp.addTask('Buy milk');
      await tp.addTask('Read book');
      await tp.addTask('Pay bills');

      final id = tp.tasks.firstWhere((t) => t.title == 'Pay bills').id;
      await tp.toggleTask(id);
    });

    test('All + query "b" returns titles containing b/B', () {
      tp.setFilter(TaskFilter.all);
      tp.setQuery('b');
      final titles = tp.tasks.map((t) => t.title.toLowerCase()).toList();
      expect(titles, contains('buy milk'));
      expect(titles, contains('read book'));
      expect(titles, contains('pay bills'));
    });

    test('Active shows only not-done', () {
      tp.setQuery('');
      tp.setFilter(TaskFilter.active);
      expect(tp.tasks.every((t) => !t.done), isTrue);
    });

    test('Done + query "pay" returns only "Pay bills"', () {
      tp.setFilter(TaskFilter.done);
      tp.setQuery('pay');
      expect(tp.tasks.length, 1);
      expect(tp.tasks.first.title, 'Pay bills');
    });
  });

  group('Home widget', () {
    testWidgets('renders PocketTasks header', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(
                create: (_) => ThemeProvider()), 
          ],
          child: const MaterialApp(
            home: Home(),
          ),
        ),
      );

      expect(find.text('PocketTasks'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });
}
