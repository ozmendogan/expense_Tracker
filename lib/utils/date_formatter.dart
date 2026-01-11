import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('d MMM yyyy', 'tr_TR').format(date);
}

