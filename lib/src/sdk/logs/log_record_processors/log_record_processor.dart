import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

abstract class LogRecordProcessor {
  void onEmit(ReadWriteLogRecord record, {api.SpanContext? spanContext});

  void shutDown();

  bool forceFlush();

}