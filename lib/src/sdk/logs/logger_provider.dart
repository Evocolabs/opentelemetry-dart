import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/api/logs/noop/noop_logger.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/logger.dart';

const int _defaultTimeout = 5000;

class LoggerProvider implements api.LoggerProvider {
  final List<LogRecordProcessor> _logRecordProcessors;
  final Map<String, api.Logger> _loggers = {};
  final sdk.Resource _resource;
  bool _shutdown = false;
  int _timeout;

  static const NoopLogger _noopLogger = NoopLogger();

  int get timeout => _timeout;
  set timeout(int timeout) {
    if (timeout < 0) {
      throw ArgumentError('timeout cannot be negative');
    }
    _timeout = timeout;
  }

  LoggerProvider(
      {sdk.Resource? resource,
      List<LogRecordProcessor>? logRecordProcessors,
      int timeout = _defaultTimeout})
      : _logRecordProcessors = logRecordProcessors ?? <LogRecordProcessor>[],
        _resource = resource ?? sdk.Resource([]),
        _timeout = timeout;

  void add_log_record_processor(LogRecordProcessor logRecordProcessor) {
    _logRecordProcessors.add(logRecordProcessor);
  }

  bool shutDown() {
    if (_shutdown) {
      return false;
    }
    try {
      for (final processor in _logRecordProcessors) {
        processor.shutDown();
      }
    } catch (e) {
      return false;
    }

    _shutdown = true;
    return true;
  }

  bool forceFlush() {
    if (_shutdown) {
      return false;
    }
    try {
      for (final processor in _logRecordProcessors) {
        processor.forceFlush();
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  // get a [Logger] identified by a name and an optional version and schemaUrl
  @override
  api.Logger getLogger(String name,
      {String version = '',
      String schemaUrl = '',
      List<Attribute> attributes = const []}) {
    if (_shutdown) {
      return _noopLogger;
    }
    final key = '$name@$version';

    return _loggers.putIfAbsent(
        key,
        () => Logger(
            _resource,
            sdk.InstrumentationScope(name, version, schemaUrl, attributes),
            _logRecordProcessors));
  }
}
