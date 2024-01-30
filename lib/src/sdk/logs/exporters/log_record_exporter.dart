import 'package:opentelemetry/src/api/logs/log_record.dart';

abstract class LogRecordExporter {
  void export(List<LogRecord> records);

  bool forceFlush();

  void shutdown();
}