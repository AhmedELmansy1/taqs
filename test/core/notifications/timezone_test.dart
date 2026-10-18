import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('Timezone initializes and creates TZDateTime', () {
    tz.initializeTimeZones();
    final cairo = tz.getLocation('Africa/Cairo');
    final nowCairo = tz.TZDateTime.now(cairo);
    expect(nowCairo.timeZoneName, isNotEmpty);
  });
}
