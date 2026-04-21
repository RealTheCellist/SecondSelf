import 'package:flutter_test/flutter_test.dart';

import 'package:second_self_mobile/app/app_shell.dart';

void main() {
  testWidgets('question screen shows initial prompt', (tester) async {
    await tester.pumpWidget(const SecondSelfApp());

    expect(find.text('오늘의 나는 어디에 가장 오래 머물렀나요?'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });
}
