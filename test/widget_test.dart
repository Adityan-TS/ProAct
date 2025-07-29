// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proact/main.dart'; // Import the main file where ProAct is defined
import 'package:supabase/supabase.dart'; // Import Supabase package

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize a dummy Supabase client for testing
    final supabaseClient = SupabaseClient(
      'https://qtljgttwigasqvkzeqxf.supabase.co', // Replace with your actual Supabase URL
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0bGpndHR3aWdhc3F2a3plcXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk5OTQ1NzUsImV4cCI6MjAzNTU3MDU3NX0.hcbOVDajJSmn7EdisH2eBeLpxOww3sSG7PVxoEsOdeU', // Replace with your actual Supabase anon key
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(ProAct());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
