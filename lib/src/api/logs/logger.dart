import 'package:opentelemetry/src/api/logs/log_record.dart';

abstract class Logger {
  void emit(LogRecord record);
}