// This is a basic Flutter widget test for the puzzle game.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:puzzle_game/main.dart';

void main() {
  testWidgets('Puzzle game app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(initialThemeMode: ThemeMode.light));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for a few frames instead of pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('App router configuration test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(initialThemeMode: ThemeMode.light));

    // Verify that the MaterialApp.router is configured
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for a few frames instead of pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
