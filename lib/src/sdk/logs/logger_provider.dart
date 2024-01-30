import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/api/logs/noop/noop_logger.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/logger.dart';

class LoggerProvider implements api.LoggerProvider {
  final List<LogRecordProcessor> _logRecordProcessors;
  final Map<String, api.Logger> _loggers = {};
  final sdk.Resource _resource;
  bool _shutdownCalled = false;

  static const NoopLogger _noopLogger = NoopLogger();

  LoggerProvider({resource, logRecordProcessors = const []})
      : _logRecordProcessors = logRecordProcessors,
        _resource = resource ?? sdk.Resource([]);

  void add_log_record_processor(LogRecordProcessor logRecordProcessor) {
    _logRecordProcessors.add(logRecordProcessor);
  }

  void shutDown() {
    //TODO: configure shutdown timeout
    if (_shutdownCalled) {
      return;
    }
    for (final processor in _logRecordProcessors) {
      processor.shutDown();
    }
    _shutdownCalled = true;
  }

  void forceFlush() {
    for (final processor in _logRecordProcessors) {
      processor.forceFlush();
    }
  }

  // get a [Logger] identified by a name and an optional version and schemaUrl
  @override
  api.Logger getLogger(String name,
      {String version = '',
      String schemaUrl = '',
      List<Attribute> attributes = const []}) {
    if (_shutdownCalled) {
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
