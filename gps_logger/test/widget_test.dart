// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gps_logger/main.dart';
import 'package:gps_logger/services/gps_storage.dart';

void main() {
  testWidgets('GPS Logger App starts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final storage = GPSJsonStorage();
    await storage.initialize();

    await tester.pumpWidget(MyApp(storage: storage));

    // Verify that the app starts and shows the GPS Logger title
    expect(find.text('GPS Logger'), findsWidgets);
  });
}
