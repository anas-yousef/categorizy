import 'package:logger/logger.dart' as logger_package;

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late final logger_package.Logger logger;
  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    logger = logger_package.Logger(
      printer: logger_package.PrettyPrinter(),
    );
  }
}
