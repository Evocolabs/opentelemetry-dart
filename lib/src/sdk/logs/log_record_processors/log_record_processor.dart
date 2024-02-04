import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

abstract class LogRecordProcessor {
  void onEmit(sdk.ReadWriteLogRecord record, {api.SpanContext? spanContext});

  void shutDown();

  void forceFlush();
}
