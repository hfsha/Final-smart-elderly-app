import 'package:intl/intl.dart';

class AppHelpers {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }
}
