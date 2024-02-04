import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:opentelemetry/src/sdk/logs/data/readable_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class SimpleLogRecordProcessor implements LogRecordProcessor {
  final LogRecordExporter _exporter;
  bool _shutdown = false;

  SimpleLogRecordProcessor(this._exporter);

  @override
  void onEmit(ReadWriteLogRecord record, {SpanContext? spanContext}) {
    if (_shutdown) {
      return;
    }
    if (spanContext != null) {
      record.spanContext = spanContext;
    }
    _exporter.export([ReadableLogRecord.convert(record)]);
  }

  @override
  void forceFlush() {
    _exporter.forceFlush();
  }

  @override
  void shutDown() {
    if (_shutdown) return;
    forceFlush();
    _exporter.shutDown();
    _shutdown = true;
  }
}
