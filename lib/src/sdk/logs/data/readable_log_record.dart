import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;
class UnmodifiableError extends Error {
  final String message;
  UnmodifiableError({this.message = 'ReadableLogRecord is unmodifiable'});
  @override
  String toString() => message;
}

class ReadableLogRecord extends sdk.LogRecordData {
  @override
  set timestamp(Int64 value) => throw UnmodifiableError();

  @override
  set observedTimestamp(Int64 value) => throw UnmodifiableError();
  
  @override
  set spanContext(api.SpanContext value) => throw UnmodifiableError();

  @override
  set severityNumber(int value) => throw UnmodifiableError();

  @override
  set severityText(api.SeverityText value) => throw UnmodifiableError();

  @override
  set body(Object value) => throw UnmodifiableError();

  @override
  set attributes(List<api.Attribute> value) => throw UnmodifiableError();

  @override
  set limits(sdk.LogRecordLimits value) => throw UnmodifiableError();

  @override
  set resource(sdk.Resource value) => throw UnmodifiableError();

  @override
  set instrumentationScope(sdk.InstrumentationScope value) => throw UnmodifiableError();

  
  ReadableLogRecord.from(
      super.resource, super.instrumentationScope, super.logRecord)
      : super.from();
  
  ReadableLogRecord.convert(sdk.LogRecordData logRecordData): super.copy(logRecordData);

  @override
  sdk.LogRecordData withLimits(sdk.LogRecordLimits limits) {
    throw UnsupportedError('Setting limits on ReadableLogRecord is not supported');
  }
}
