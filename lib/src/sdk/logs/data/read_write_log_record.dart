import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';

class ReadWriteLogRecord implements LogRecordData {
  @override
  final Int64 timestamp;

  @override
  Int64 observedTimestamp;

  @override
  SpanContext spanContext;

  @override
  int severityNumber;

  @override
  SeverityText severityText;

  @override
  String body;

  @override
  List<api.Attribute> attributes;

  @override
  sdk.Resource resource;

  @override
  sdk.InstrumentationScope instrumentationScope;

  @protected
  ReadWriteLogRecord(
      this.timestamp,
      this.observedTimestamp,
      this.spanContext,
      this.severityNumber,
      this.severityText,
      this.body,
      this.attributes,
      this.resource,
      this.instrumentationScope);

  ReadWriteLogRecord.from(sdk.Resource resource,
      sdk.InstrumentationScope instrumentationScope, LogRecord logRecord)
      : this(
            logRecord.timestamp,
            logRecord.observedTimestamp,
            logRecord.spanContext,
            logRecord.severityNumber,
            logRecord.severityText,
            logRecord.body,
            logRecord.attributes,
            resource,
            instrumentationScope);
}
