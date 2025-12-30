import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000';
  // Other constants we might need later
  static const String appName = "Flowly";
}
