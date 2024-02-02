import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_limits.dart';

class UnmodifiableError extends Error {
  final String message;
  UnmodifiableError({this.message = 'ReadableLogRecord is unmodifiable'});
  @override
  String toString() => message;
}

class ReadableLogRecord extends LogRecordData {
  @override
  set timestamp(Int64 value) => throw UnmodifiableError();

  @override
  set observedTimestamp(Int64 value) => throw UnmodifiableError();
  
  @override
  set spanContext(SpanContext value) => throw UnmodifiableError();

  @override
  set severityNumber(int value) => throw UnmodifiableError();

  @override
  set severityText(SeverityText value) => throw UnmodifiableError();

  @override
  set body(Object value) => throw UnmodifiableError();

  @override
  set attributes(List<Attribute> value) => throw UnmodifiableError();

  @override
  set limits(LogRecordLimits value) => throw UnmodifiableError();

  @override
  set resource(Resource value) => throw UnmodifiableError();

  @override
  set instrumentationScope(InstrumentationScope value) => throw UnmodifiableError();

  
  ReadableLogRecord.from(
      super.resource, super.instrumentationScope, super.logRecord)
      : super.from();
  
  ReadableLogRecord.convert(LogRecordData logRecordData): super.copy(logRecordData);

  @override
  LogRecordData withLimits(LogRecordLimits limits) {
    throw UnsupportedError('Setting limits on ReadableLogRecord is not supported');
  }
}
