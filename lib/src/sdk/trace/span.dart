import '../../api/trace/span_status.dart';
import '../../api/trace/span.dart' as span_api;
import '../../api/trace/span_context.dart';
import 'span_processors/span_processor.dart';

/// A representation of a single operation within a trace.
class Span implements span_api.Span {
  int _startTime;
  int _endTime;
  final String _parentSpanId;
  final SpanContext _spanContext;
  final SpanStatus _status = SpanStatus();
  final List<SpanProcessor> _processors;

  @override
  String name;

  /// Construct a [Span].
  Span(
    this.name, 
    this._spanContext, 
    this._parentSpanId,
    this._processors
  ) {
    _startTime = DateTime.now().toUtc().microsecondsSinceEpoch;
    for (var i = 0; i < _processors.length; i++) {
      _processors[i].onStart();
    }
  }

  @override
  SpanContext get spanContext => _spanContext;

  @override
  int get endTime => _endTime;

  @override
  int get startTime => _startTime;

  @override
  String get parentSpanId => _parentSpanId;

  @override
  void end() {
    _endTime ??= DateTime.now().toUtc().microsecondsSinceEpoch;
    for (var i = 0; i < _processors.length; i++) {
      _processors[i].onEnd(this);
    }
  }

  @override
  void setStatus(StatusCode status, {String description}) {
    // A status cannot be Unset after being set, and cannot be set to any other
    // status after being marked "Ok".
    if (status == StatusCode.UNSET || _status.code == StatusCode.OK) {
      return;
    }

    _status.code = status;

    // Description is ignored for statuses other than "Error".
    if (status == StatusCode.ERROR && description != null) {
      _status.description = description;
    }
  }

  @override
  SpanStatus get status => _status;
}
