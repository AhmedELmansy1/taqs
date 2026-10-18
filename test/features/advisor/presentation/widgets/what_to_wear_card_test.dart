import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/advisor/domain/entities/clothing_advice.dart';
import 'package:taqs/features/advisor/presentation/widgets/what_to_wear_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('WhatToWearCard', () {
    const advice = ClothingAdvice(
      headlineAr: 'ملابس صيفية خفيفة وقطنية',
      headlineEn: 'Light summer breathable wear',
      detailsAr: 'الطقس دافئ ومثالي للأنشطة الخارجية.',
      detailsEn: 'Weather is warm and ideal for outdoor activities.',
      seasonTagAr: 'طراز صيفي',
      seasonTagEn: 'Summer Style',
      itemsAr: [
        'قميص قطني مريح',
        'نظارة شمسية واقية',
        'حذاء خفيف ومريح',
      ],
      itemsEn: [
        'Cotton t-shirt',
        'UV sunglasses',
        'Comfortable footwear',
      ],
    );

    testWidgets('renders headline, details, tag, and item chips in Arabic',
        (tester) async {
      await tester.pumpApp(
        const WhatToWearCard(
          advice: advice,
          isArabic: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ماذا أرتدي اليوم؟'), findsOneWidget);
      expect(find.text('طراز صيفي'), findsOneWidget);
      expect(find.text('ملابس صيفية خفيفة وقطنية'), findsOneWidget);
      expect(find.text('الطقس دافئ ومثالي للأنشطة الخارجية.'), findsOneWidget);
      expect(find.text('قميص قطني مريح'), findsOneWidget);
      expect(find.text('نظارة شمسية واقية'), findsOneWidget);
    });

    testWidgets('renders headline, details, and items in English',
        (tester) async {
      await tester.pumpApp(
        const WhatToWearCard(
          advice: advice,
          isArabic: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What to wear today?'), findsOneWidget);
      expect(find.text('Summer Style'), findsOneWidget);
      expect(find.text('Light summer breathable wear'), findsOneWidget);
      expect(find.text('Cotton t-shirt'), findsOneWidget);
    });
  });
}
