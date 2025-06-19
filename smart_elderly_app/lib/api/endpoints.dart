class Endpoints {
  static const String baseUrl =
      'https://humancc.site/shahidatulhidayah/smart-elderly-app/api';

  // Authentication
  static String login = '$baseUrl/auth/login.php';
  static String register = '$baseUrl/auth/register.php';

  // Sensor Data
  static String sensorData = '$baseUrl/sensor/data.php';
  static String sensorTrends = '$baseUrl/sensor/trends.php';

  // Alerts
  static String alerts = '$baseUrl/alerts/list.php';
  static String handleAlert = '$baseUrl/alerts/handle.php';
}
