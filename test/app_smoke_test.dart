import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alqoud_social/main.dart';

void main() {
  testWidgets('shows Firebase setup guidance when Firebase is not configured',
      (tester) async {
    await tester.pumpWidget(const AlQoudSocialApp(firebaseReady: false));

    expect(find.text('بقي ربط خدمات التطبيق'), findsOneWidget);
    expect(find.textContaining('إعدادات Firebase'), findsOneWidget);

    final titleContext = tester.element(find.text('بقي ربط خدمات التطبيق'));
    expect(Directionality.of(titleContext), TextDirection.rtl);
  });
}
