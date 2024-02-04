import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class SimpleLogRecordProcessor implements sdk.LogRecordProcessor {
  final sdk.LogRecordExporter _exporter;
  bool _shutdown = false;

  SimpleLogRecordProcessor(this._exporter);

  @override
  void onEmit(sdk.ReadWriteLogRecord record, {api.SpanContext? spanContext}) {
    if (_shutdown) {
      return;
    }
    if (spanContext != null) {
      record.spanContext = spanContext;
    }
    _exporter.export([sdk.ReadableLogRecord.convert(record)]);
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
