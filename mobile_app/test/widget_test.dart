import 'package:flutter_test/flutter_test.dart';

import 'package:second_self_mobile/app/app_shell.dart';

void main() {
  testWidgets('question screen shows initial prompt', (tester) async {
    await tester.pumpWidget(const SecondSelfApp());

    expect(find.text('Where has your mind been most often today?'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
