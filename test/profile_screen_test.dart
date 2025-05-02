import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen basic UI renders correctly',
      (WidgetTester tester) async {
    // Create a mock user
    final userModel = UserModel(
      id: 'user123',
      fullName: 'Test User',
      dateOfBirth: '1990-01-01',
      gender: 'Male',
      nic: '123456789V',
      contact: '0712345678',
      address: '123 Test Street',
      city: 'Testville',
      isDonor: true,
      bloodType: 'O+',
      organType: 'Kidney',
      hlaTyping: {
        'A': '01',
        'B': '08',
        'C': '07',
      },
      isTestsCompleted: true,
      history: ['No prior donation'],
      waitingTime: 5,
      imageUrl: '',
      medicalDocuments: {},
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          isDonor: true,
          userModel: userModel,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check for user's full name
    expect(find.text('Test User'), findsOneWidget);

    // Check for profile buttons
    expect(find.text('Personal Info'), findsOneWidget);
    expect(find.text('Medical Info'), findsOneWidget);
    expect(find.text('Donation Status'), findsOneWidget);
    expect(find.text('Donation History'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Check that the profile image button is present
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
