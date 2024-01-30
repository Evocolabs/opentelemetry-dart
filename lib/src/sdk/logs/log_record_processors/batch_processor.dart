import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class BatchProcessor implements LogRecordProcessor {
  @override
  bool forceFlush() {
    // TODO: implement forceFlush
    return true;
  }

  @override
  void onEmit(ReadWriteLogRecord record, {SpanContext? spanContext}) {
    // TODO: implement onEmit
  }

  @override
  void shutDown() {
    // TODO: implement shutDown
  }
  
}