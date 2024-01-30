import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart';

enum SeverityText { trace, debug, info, warn, error, fatal, unknown }

// Log Record conforms to the OpenTelemetry specification for Log Data Model
class LogRecord {
  final Int64 _timestamp;
  final Int64 _observedTimestamp;
  final SpanContext _spanContext;
  final int _severityNumber;
  final SeverityText _severityText;
  final String _body;
  final List<Attribute> _attributes;

  @protected
  LogRecord(
      this._timestamp,
      this._observedTimestamp,
      this._spanContext,
      this._severityNumber,
      this._severityText,
      this._body,
      this._attributes);

  LogRecord.create(
      {timestamp,
      observedTimestamp,
      spanContext,
      severityNumber = 0,
      severityText = SeverityText.unknown,
      body='',
      attributes=const []})
      : _timestamp = timestamp ??
            observedTimestamp ??
            Int64(DateTime.now().millisecondsSinceEpoch),
        _observedTimestamp =
            observedTimestamp ?? Int64(DateTime.now().millisecondsSinceEpoch),
        _spanContext = spanContext ?? SpanContext.invalid(),
        _severityNumber = severityNumber,
        _severityText = severityText,
        _body = body,
        _attributes = attributes;

  Int64 get timestamp => _timestamp;

  Int64 get observedTimestamp => _observedTimestamp;

  SpanContext get spanContext => _spanContext;

  int get severityNumber => _severityNumber;

  SeverityText get severityText => _severityText;

  String get body => _body;

  List<Attribute> get attributes => _attributes;
}
