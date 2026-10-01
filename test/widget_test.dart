// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/auth/splash_screen.dart';
import 'package:flutter_application_1/widgets/medical_logo.dart';

void main() {
  testWidgets('MediQueue starts on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediQueueApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(MedicalLogo), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
