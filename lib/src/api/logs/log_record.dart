import 'package:opentelemetry/api.dart';

enum SeverityText {
  trace,
  debug,
  info,
  warn,
  error,
  fatal,
}

// Log Record conforms to the OpenTelemetry specification for Log Data Model
class LogRecord {
  int? timestamp;
  int observedTimestamp;
  TraceId? traceId;
  SpanId? spanId;
  TraceFlags? traceFlags;
  int? severityNumber;
  SeverityText? severityText;
  String? body;
  List<Attribute>? attributes;

  LogRecord(
      {this.timestamp,
      int? observedTimestamp,
      this.traceId,
      this.spanId,
      this.traceFlags,
      this.severityNumber,
      this.severityText,
      this.body,
      this.attributes}): observedTimestamp = observedTimestamp ?? DateTime.now().millisecondsSinceEpoch;
}
