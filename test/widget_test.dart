// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dplayer/main.dart';

void main() {
  testWidgets('DPlayer app renders main navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPlayerApp());

    expect(find.text('dplayer'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
  });
}
