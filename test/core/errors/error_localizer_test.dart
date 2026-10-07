import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/core/errors/error_localizer.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('ErrorLocalizer', () {
    testWidgets('maps NoConnectionFailure to localized Arabic message',
        (tester) async {
      late String localizedMessage;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            localizedMessage = ErrorLocalizer.localize(
              context,
              const NoConnectionFailure(),
            );
            return const SizedBox.shrink();
          },
        ),
      );

      expect(localizedMessage, contains('لا يوجد اتصال بالإنترنت'));
    });

    testWidgets('maps TimeoutFailure to localized message', (tester) async {
      late String localizedMessage;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            localizedMessage = ErrorLocalizer.localize(
              context,
              const TimeoutFailure(),
            );
            return const SizedBox.shrink();
          },
        ),
      );

      expect(localizedMessage, contains('استغرقت الاستجابة وقتاً'));
    });
  });
}
