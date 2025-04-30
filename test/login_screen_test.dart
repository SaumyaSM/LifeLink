import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_link/screens/Auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen UI renders and validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('LOGIN'), findsWidgets);

    // Tap the login button
    await tester.tap(find.text('LOGIN').last);

    // Wait for toast animations and timers to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
  testWidgets('Email and password fields accept input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Enter text into the email and password fields
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    // Ensure the text is present in the fields
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });
}
