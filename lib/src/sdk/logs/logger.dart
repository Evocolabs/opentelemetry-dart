import 'package:meta/meta.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class Logger implements api.Logger {
  final sdk.Resource _resource;
  final sdk.InstrumentationScope _instrumentationScope;
  final List<sdk.LogRecordProcessor> _logRecordProcessors;

  @protected
  const Logger(
      this._resource, this._instrumentationScope, this._logRecordProcessors);

  @override
  void emit(api.LogRecord record) {
    final readWriteLogRecord =
        sdk.ReadWriteLogRecord.from(_resource, _instrumentationScope, record);
    for (final processor in _logRecordProcessors) {
      processor.onEmit(readWriteLogRecord);
    }
  }
}
