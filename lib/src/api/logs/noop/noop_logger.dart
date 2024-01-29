import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/api/logs/logger.dart';

// A noop logger that does nothing.
class NoopLogger implements Logger {
  @override
  void emit(LogRecord record) {}
}