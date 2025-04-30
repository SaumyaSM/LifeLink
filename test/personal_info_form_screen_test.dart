import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';

/// A simplified test that uses a test-friendly wrapper around the personal info form
void main() {
  testWidgets('PersonalInfoFormScreen renders basic UI elements',
      (WidgetTester tester) async {
    // Define screen size that matches test environment (800x600)
    tester.binding.window.physicalSizeTestValue = const Size(800, 600);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Create a minimal UserModel for testing
    final userModel = UserModel(
      id: 'test_id',
      fullName: '',
      dateOfBirth: '',
      gender: '',
      nic: '',
      contact: '',
      address: '',
      city: '',
      isDonor: true,
      bloodType: '',
      organType: '',
      isTestsCompleted: false,
      history: [],
      hlaTyping: {},
      waitingTime: 0,
      imageUrl: '',
    );

    // Build the widget with a test-friendly wrapper
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          // Set a fixed size that works with test environment
          data: const MediaQueryData(
            size: Size(800, 600),
            padding: EdgeInsets.zero,
          ),
          child: TestFormWrapper(
            child: PersonalInfoFormScreen(
              isDonor: true,
              userModel: userModel,
            ),
          ),
        ),
      ),
    );

    // Verify header text is present (this is in the banner)
    expect(find.text('DONATOR!'), findsOneWidget);

    // Verify form title is present
    expect(find.text('Fill in your personal details'), findsOneWidget);

    // Scroll to see more elements and pump to process the scroll
    await tester.dragFrom(
        tester.getCenter(find.text('Fill in your personal details')),
        const Offset(0, -300));
    await tester.pump();

    // Verify some form fields are present after scrolling
    expect(find.text('Full Name'), findsOneWidget);

    // Scroll more to see gender options
    await tester.dragFrom(
        tester.getCenter(find.text('Full Name')), const Offset(0, -200));
    await tester.pump();

    // Verify gender fields
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    // Scroll more to see remaining fields
    await tester.dragFrom(
        tester.getCenter(find.text('Gender')), const Offset(0, -200));
    await tester.pump();

    // Test finds at least one of the fields in the bottom section
    expect(find.text('NIC'), findsOneWidget);
  });
}

/// A test helper widget that provides a fixed-height scrollable container
/// to avoid overflow errors in test environment
class TestFormWrapper extends StatelessWidget {
  final Widget child;

  const TestFormWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 800,
        height: 600,
        child: child,
      ),
    );
  }
}
