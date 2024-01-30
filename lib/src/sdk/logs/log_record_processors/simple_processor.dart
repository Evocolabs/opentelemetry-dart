import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:opentelemetry/src/sdk/logs/data/readable_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class SimpleProcessor implements LogRecordProcessor {
  final LogRecordExporter exporter;
  bool _shutdown = false;

  SimpleProcessor(this.exporter);

  @override
  void onEmit(ReadWriteLogRecord record, {SpanContext? spanContext}) {
    if (spanContext != null) {
      record.spanContext = spanContext;
    }
    exporter.export([ReadableLogRecord.from(record.resource, record.instrumentationScope, record)]);
  }

  @override
  bool forceFlush() {
    return true;
  }

  @override
  void shutDown() {
    if (_shutdown) {
      return;
    }
    exporter.shutdown();
    _shutdown = true;
  }
}
