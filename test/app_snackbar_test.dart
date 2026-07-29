import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/widgets/app_snackbar.dart';

import 'helpers/test_harness.dart';

void main() {
  testWidgets('shows the message with the short 1.5s duration', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      wrapScaffold(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    AppSnackBar.show(ScaffoldMessenger.of(capturedContext), 'Hello');
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, AppSnackBar.duration);
    expect(AppSnackBar.duration, const Duration(milliseconds: 1500));
  });

  testWidgets('rapid repeated calls replace the message instead of queuing', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      wrapScaffold(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // Simulate quickly toggling a switch on/off several times: each call
    // fires before the previous snackbar's duration would have elapsed.
    AppSnackBar.show(ScaffoldMessenger.of(capturedContext), 'On');
    await tester.pump();
    AppSnackBar.show(ScaffoldMessenger.of(capturedContext), 'Off');
    await tester.pump();
    AppSnackBar.show(ScaffoldMessenger.of(capturedContext), 'On');
    await tester.pump();

    // Only the latest message is visible — nothing queued to show later.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
    expect(find.text('Off'), findsNothing);
  });
}
