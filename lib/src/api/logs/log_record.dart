import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart';

enum SeverityText { trace, debug, info, warn, error, fatal, unknown }

// Log Record conforms to the OpenTelemetry specification for Log Data Model
class LogRecord {
  Int64 timestamp;
  Int64 observedTimestamp;
  SpanContext spanContext;
  int severityNumber;
  SeverityText severityText;
  String body;
  List<Attribute> attributes;

  @protected
  LogRecord(
      this.timestamp,
      this.observedTimestamp,
      this.spanContext,
      this.severityNumber,
      this.severityText,
      this.body,
      this.attributes);

  LogRecord.create(
      {Int64? timestamp,
      Int64? observedTimestamp,
      SpanContext? spanContext,
      this.severityNumber = 0,
      this.severityText = SeverityText.unknown,
      this.body='',
      List<Attribute>? attributes})
      : timestamp = timestamp ??
            observedTimestamp ??
            Int64(DateTime.now().millisecondsSinceEpoch),
        observedTimestamp =
            observedTimestamp ?? Int64(DateTime.now().millisecondsSinceEpoch),
        spanContext = spanContext ?? SpanContext.invalid(),
        attributes = attributes ?? [];
}
