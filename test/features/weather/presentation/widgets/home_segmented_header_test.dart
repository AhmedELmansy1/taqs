import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/features/weather/presentation/controllers/home_tab_controller.dart';
import 'package:taqs/features/weather/presentation/widgets/home_segmented_header.dart';

void main() {
  testWidgets('HomeSegmentedHeader renders Weather and Prayer tabs with proper selection',
      (tester) async {
    var activeTab = HomeTab.weather;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return HomeSegmentedHeader(
                selectedTab: activeTab,
                isArabic: true,
                onTabChanged: (tab) {
                  setState(() {
                    activeTab = tab;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Weather and Prayer labels in Arabic
    expect(find.text('الطقس'), findsOneWidget);
    expect(find.text('مواقيت الصلاة'), findsOneWidget);

    // Tap on Prayer tab
    await tester.tap(find.text('مواقيت الصلاة'));
    await tester.pumpAndSettle();

    expect(activeTab, HomeTab.prayer);
  });

  testWidgets('HomeSegmentedHeader renders English labels correctly',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HomeSegmentedHeader(
            selectedTab: HomeTab.prayer,
            isArabic: false,
            onTabChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Prayer Times'), findsOneWidget);
  });
}
