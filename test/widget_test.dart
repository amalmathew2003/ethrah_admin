// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethrah_admin/main.dart';

void main() {
  testWidgets('Admin Home Screen Load Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This will likely fail in testing environment due to actual Supabase initialization in main()
    // but at least it fixes the code reference.
    await tester.pumpWidget(const EthrahAdminApp());
  });
}
