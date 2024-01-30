import 'package:meta/meta.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class Logger implements api.Logger {
  final Resource _resource;
  final InstrumentationScope _instrumentationScope;
  final List<LogRecordProcessor> _logRecordProcessors;

  @protected
  const Logger(this._resource, this._instrumentationScope, this._logRecordProcessors);


  @override
  void emit(api.LogRecord record) {
    final readWriteLogRecord = ReadWriteLogRecord.from(_resource, _instrumentationScope, record);
    for (final processor in _logRecordProcessors) {
      processor.onEmit(readWriteLogRecord);
    }
  }

}