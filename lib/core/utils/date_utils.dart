import 'package:intl/intl.dart';

extension AppDateUtils on DateTime {
  String get shortDate => DateFormat('d MMM yyyy', 'ru').format(this);
  String get shortDateNoYear => DateFormat('d MMM', 'ru').format(this);
  String get monthYear => DateFormat('MMMM yyyy', 'ru').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  DateTime get dateOnly => DateTime(year, month, day);
}
