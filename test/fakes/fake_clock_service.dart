import 'package:gymstreak/app/utils/clock_service.dart';

/// [ClockService] yang waktunya bisa diatur manual, khusus untuk testing.
class FakeClockService extends ClockService {
  FakeClockService(this._now);

  DateTime _now;

  void setNow(DateTime value) => _now = value;

  @override
  DateTime now() => _now;
}
