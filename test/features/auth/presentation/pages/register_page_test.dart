import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/core/services/photo_picker_service.dart';
import 'package:rdpms_app/core/widgets/gradient_button.dart';
import 'package:rdpms_app/features/auth/presentation/pages/register_page.dart';

class MockPhotoPicker extends Mock implements PhotoPickerService {}

void main() {
  late MockPhotoPicker picker;

  setUpAll(() => registerFallbackValue(PhotoSource.gallery));
  setUp(() => picker = MockPhotoPicker());

  Future<void> pumpPage(WidgetTester tester) =>
      tester.pumpWidget(MaterialApp(home: RegisterPage(photoPicker: picker)));

  testWidgets('shows the Add photo option above the form', (tester) async {
    await pumpPage(tester);

    expect(find.text('Add photo'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
  });

  testWidgets('Submit is pinned at the bottom with a Sign in link', (tester) async {
    await pumpPage(tester);

    final submit = find.widgetWithText(GradientButton, 'Submit request');
    expect(submit, findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sign in'), findsOneWidget);

    // Visible without scrolling: the button sits in the bottom part of the screen.
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(submit).dy, greaterThan(screenHeight * 0.75));
  });

  testWidgets('Submit validates fields that are scrolled off screen', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(GradientButton, 'Submit request'));
    await tester.pump();

    expect(find.text('Select jurisdiction'), findsOneWidget);
  });

  testWidgets('picking from the gallery shows Change photo and allows Remove', (tester) async {
    when(() => picker.pick(PhotoSource.gallery)).thenAnswer((_) async => '/tmp/photo.jpg');
    await pumpPage(tester);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Remove photo'), findsNothing);

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    verify(() => picker.pick(PhotoSource.gallery)).called(1);
    expect(find.text('Change photo'), findsOneWidget);

    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();

    expect(find.text('Add photo'), findsOneWidget);
  });

  testWidgets('cancelling the picker keeps the placeholder', (tester) async {
    when(() => picker.pick(any())).thenAnswer((_) async => null);
    await pumpPage(tester);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(find.text('Add photo'), findsOneWidget);
  });

  testWidgets('a denied permission shows a message instead of crashing', (tester) async {
    when(() => picker.pick(PhotoSource.camera))
        .thenThrow(PlatformException(code: 'camera_access_denied'));
    await pumpPage(tester);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera not available. Allow camera access in Settings.'), findsOneWidget);
  });
}
