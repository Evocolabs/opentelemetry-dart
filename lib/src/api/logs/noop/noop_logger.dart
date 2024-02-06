import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/api/logs/logger.dart';

// A noop logger that does nothing.
// See https://opentelemetry.io/docs/specs/otel/logs/noop/ for more information.
class NoopLogger implements Logger {
  const NoopLogger();
  
  @override
  void emit(LogRecord record) {}
}