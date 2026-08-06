/// Sumber waktu tunggal untuk seluruh aplikasi. Jangan memanggil
/// `DateTime.now()` langsung di controller/service/repository — gunakan
/// [ClockService.now] agar waktu bisa di-mock saat unit test.
class ClockService {
  DateTime now() => DateTime.now();
}
