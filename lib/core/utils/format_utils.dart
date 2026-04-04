import 'package:intl/intl.dart';

class FormatUtils {
  static final _htgFormatter = NumberFormat.currency(
    locale: 'fr_HT',
    symbol: 'HTG ',
    decimalDigits: 2,
  );

  static String htg(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    return _htgFormatter.format(value);
  }

  static String date(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String dateHeure(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
