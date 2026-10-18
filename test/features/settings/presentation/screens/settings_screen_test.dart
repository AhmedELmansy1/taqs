import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/settings/presentation/screens/settings_screen.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders appearance, language, notifications, and about navigation tiles',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const SettingsScreen(),
      );
      await tester.pumpAndSettle();

      // Check section titles
      expect(find.text('المظهر والعرض'), findsOneWidget);
      expect(find.text('اللغة والمنطقة'), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('مواقيت الصلاة والتنبيهات'), findsOneWidget);
      expect(find.text('الأنماط الذكية'), findsOneWidget);
      expect(find.text('عن التطبيق'), findsOneWidget);

      // Check Theme Mode segmented button segments
      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);

      // Check Language Options
      expect(find.text('العربية (Arabic)'), findsOneWidget);
      expect(find.text('الإنجليزية (English)'), findsOneWidget);

      // Check Notification Toggles
      expect(find.text('تنبيهات الطقس الحرج (الخماسين والشبورة)'), findsOneWidget);
      expect(find.text('الملخص اليومي الصباحي'), findsOneWidget);

      // Check About Developer tile
      expect(find.text('عن المطور'), findsOneWidget);
    });

    testWidgets('allows tapping language options', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
      );
      await tester.pumpAndSettle();

      // Tap English option
      await tester.tap(find.text('الإنجليزية (English)'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
