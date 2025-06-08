import 'package:intl/intl.dart';

import 'app_strings.dart';

class AppConvert {
  /// 2025-05-25T12:00:00.000+00:00 -> 25/05/2025
  static String convertIsoDateToFormattedDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return AppStrings.hifen;
    }

    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return AppStrings.hifen;
    }
  }

  /// Converte uma data no formato "dd/MM/yyyy" para uma string no formato ISO 8601.
  static String? convertDateToIso(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }
    try {
      final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      final DateTime dateTime = inputFormat.parse(date);
      // Formato que o backend Java entende
      return dateTime.toIso8601String();
    } catch (e) {
      return null;
    }
  }
}
