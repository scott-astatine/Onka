import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// It's best practice to use package imports. Assuming your package name is 'onka'.
// If your package name is different, update the import path accordingly.
// e.g., import 'package:your_package_name/main.dart';
import 'package:onka/main.dart';

void main() {
  // Grouping tests is a good practice for organizing your test suite.
  group('OnkaApp Initialization', () {
    // A helper function to create the widget under test.
    // This avoids repetition and makes tests cleaner.
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        // ProviderScope is required for Riverpod to work.
        const ProviderScope(
          // Assuming your main app widget is OnkaApp and follows UpperCamelCase convention.
          child: OnkaApp(),
        ),
      );
    }

    testWidgets('should build and display MaterialApp without crashing',
        (WidgetTester tester) async {
      // Arrange: Build the app.
      await pumpApp(tester);

      // Assert: Verify that MaterialApp is present. This is a good "smoke test"
      // to ensure the app's root widget structure is correct.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('initial screen should contain a Scaffold',
        (WidgetTester tester) async {
      // Arrange
      await pumpApp(tester);

      // Assert
      // Most apps have a Scaffold on their main screen. This test verifies
      // that the basic layout is in place.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // This is an example of a more specific UI test.
    // You should adapt it to match your application's UI.
    testWidgets('initial screen should have an AppBar with a title',
        (WidgetTester tester) async {
      // Arrange
      await pumpApp(tester);

      // Assert
      // 1. Find the AppBar widget.
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      // 2. Verify the title within the AppBar.
      // This is more specific than just finding any Text widget.
      // Replace 'Onka' with your actual app title.
      final titleFinder = find.descendant(
        of: appBarFinder,
        matching: find.text('Onka'),
      );
      expect(titleFinder, findsOneWidget);
    });
  });
}
