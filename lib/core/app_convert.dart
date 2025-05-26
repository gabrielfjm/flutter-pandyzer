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
}
