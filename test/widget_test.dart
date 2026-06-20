import 'package:flutter_test/flutter_test.dart';
import 'package:trust_circle/main.dart';

void main() {
  testWidgets('Splash screen shows TrustCircle title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrustCircleApp());

    // Verify that Splash Screen shows the title 'TrustCircle'
    expect(find.text('TrustCircle'), findsOneWidget);
  });
}
