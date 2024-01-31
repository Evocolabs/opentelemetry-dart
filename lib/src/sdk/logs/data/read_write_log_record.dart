import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';

class ReadWriteLogRecord extends LogRecordData {
  ReadWriteLogRecord.from(sdk.Resource resource,
      sdk.InstrumentationScope instrumentationScope, LogRecord logRecord)
      : super.from(resource, instrumentationScope, logRecord);
    
  ReadWriteLogRecord.convert(LogRecordData logRecordData): super.copy(logRecordData);
}
