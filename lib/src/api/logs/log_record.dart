import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';

enum SeverityText { trace, debug, info, warn, error, fatal, unknown }

/// Log Record conforms to the OpenTelemetry specification for Log Data Model
class LogRecord {
  static final DateTimeTimeProvider _timeProvider = DateTimeTimeProvider();

  /// Time when the event occurred measured by the origin clock, i.e. the time at the source.
  /// This field is optional, it may be missing if the source timestamp is unknown.
  Int64 timestamp;

  /// Time when the event was observed by the collection system.
  /// This field SHOULD be set once the event is observed by OpenTelemetry.
  /// For converting OpenTelemetry log data to formats that support only one timestamp or when receiving OpenTelemetry log data by recipients 
  /// that support only one timestamp internally the following logic is recommended:
  ///   - Use Timestamp if it is present, otherwise use ObservedTimestamp.
  Int64 observedTimestamp;

  /// SpanContext contains three fields: traceId, spanId, and traceFlags.
  /// traceId: Request trace id as defined in W3C Trace Context. 
  /// Can be set for logs that are part of request processing and have an assigned trace id. 
  /// spanId: Can be set for logs that are part of a particular processing span. 
  /// If SpanId is present TraceId SHOULD be also present. 
  /// traceFlags: Trace flag as defined in W3C Trace Context specification. 
  /// At the time of writing the specification defines one flag - the SAMPLED flag. 
  SpanContext spanContext;

  // Numerical value of the severity, normalized to values described in this document.
  int severityNumber;

  /// Severity text (also known as log level). 
  /// This is the original string representation of the severity as it is known at the source. 
  /// If this field is missing and SeverityNumber is present then the short name that corresponds to the SeverityNumber may be used as a substitution. 
  SeverityText severityText;

  /// A value containing the body of the log record.
  /// Can be for example a human-readable string message (including multi-line) describing the event in a free form or it can be a structured data composed of arrays and maps of other values. 
  /// First-party Applications SHOULD use a string message. 
  /// However, a structured body SHOULD be used to preserve the semantics of structured logs emitted by Third-party Applications.
  /// Can vary for each occurrence of the event coming from the same source.
  Object body;

  /// Additional information about the specific event occurrence. 
  /// Unlike the Resource field, which is fixed for a particular source, 
  /// Attributes can vary for each occurrence of the event coming from the same source. 
  /// Can contain information about the request context (other than TraceId/SpanId). 
  /// SHOULD follow OpenTelemetry semantic conventions for attributes.
  List<Attribute> attributes;

  @protected
  LogRecord(this.timestamp, this.observedTimestamp, this.spanContext,
      this.severityNumber, this.severityText, this.body, this.attributes);

  LogRecord.create(
      {Int64? timestamp,
      Int64? observedTimestamp,
      SpanContext? spanContext,
      this.severityNumber = 0,
      this.severityText = SeverityText.unknown,
      this.body = '',
      List<Attribute>? attributes})
      : timestamp = timestamp ?? observedTimestamp ?? _timeProvider.now,
        observedTimestamp = observedTimestamp ?? _timeProvider.now,
        spanContext = spanContext ?? SpanContext.invalid(),
        attributes = attributes ?? <Attribute>[];

  /// Record exception and stack trace(if any) to attributes of logRecord.
  void recordException(dynamic exception,
      {StackTrace stackTrace = StackTrace.empty}) {
    [
      Attribute.fromString(
          SemanticAttributes.exceptionType, exception.runtimeType.toString()),
      Attribute.fromString(
          SemanticAttributes.exceptionMessage, exception.toString()),
      Attribute.fromString(
          SemanticAttributes.exceptionStacktrace, stackTrace.toString())
    ].forEach(addAttribute);
  }
  /// Add an attribute to the log record.
  void addAttribute(Attribute attr) {
    attributes.add(attr);
  }
}
