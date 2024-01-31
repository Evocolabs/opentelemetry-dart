import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:opentelemetry/src/sdk/logs/data/readable_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class SimpleLogRecordProcessor implements LogRecordProcessor {
  final LogRecordExporter exporter;
  bool _shutdown = false;

  SimpleLogRecordProcessor(this.exporter);

  @override
  void onEmit(ReadWriteLogRecord record, {SpanContext? spanContext}) {
    if (_shutdown) {
      return;
    }
    if (spanContext != null) {
      record.spanContext = spanContext;
    }
    exporter.export([
      ReadableLogRecord.convert(record)
    ]);
  }

  @override
  bool forceFlush() {
    return true;
  }

  @override
  bool shutDown() {
    if (_shutdown) return false;
    forceFlush();
    if (!exporter.shutDown()) return false;
    _shutdown = true;
    return true;
  }
}
