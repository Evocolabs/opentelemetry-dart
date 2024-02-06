import 'package:logging/logging.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

const int _defaultTimeout = 5000;

class LoggerProvider implements api.LoggerProvider {
  final List<sdk.LogRecordProcessor> _logRecordProcessors;
  final Map<String, api.Logger> _loggers = {};
  final sdk.Resource _resource;
  bool _shutdown = false;
  int _timeout;
  final Logger _logger = Logger('LoggerProvider');

  static const api.NoopLogger _noopLogger = api.NoopLogger();

  int get timeout => _timeout;
  set timeout(int timeout) {
    if (timeout < 0) {
      throw ArgumentError('timeout cannot be negative');
    }
    _timeout = timeout;
  }

  LoggerProvider(
      {sdk.Resource? resource,
      List<sdk.LogRecordProcessor>? logRecordProcessors,
      int timeout = _defaultTimeout})
      : _logRecordProcessors =
            logRecordProcessors ?? <sdk.LogRecordProcessor>[],
        _resource = resource ?? sdk.Resource([]),
        _timeout = timeout;

  void add_log_record_processor(sdk.LogRecordProcessor logRecordProcessor) {
    _logRecordProcessors.add(logRecordProcessor);
  }

  void shutDown() {
    if (_shutdown) {
      return;
    }
    try {
      for (final processor in _logRecordProcessors) {
        processor.shutDown();
      }
    } catch (e) {
      _logger.warning('Error while shutting down log record processors: $e');
    }

    _shutdown = true;
  }

  void forceFlush() {
    if (_shutdown) {
      return;
    }
    try {
      for (final processor in _logRecordProcessors) {
        processor.forceFlush();
      }
    } catch (e) {
      _logger.warning('Error while flushing log record processors: $e');
    }
  }

  // get a [Logger] identified by a name and an optional version and schemaUrl
  @override
  api.Logger getLogger(String name,
      {String version = '',
      String schemaUrl = '',
      List<api.Attribute> attributes = const []}) {
    if (_shutdown) {
      return _noopLogger;
    }
    final key = '$name@$version';

    return _loggers.putIfAbsent(
        key,
        () => sdk.Logger(
            _resource,
            sdk.InstrumentationScope(name, version, schemaUrl, attributes),
            _logRecordProcessors));
  }
}
