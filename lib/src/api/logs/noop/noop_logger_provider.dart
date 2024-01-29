import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/api/logs/logger.dart';
import 'package:opentelemetry/src/api/logs/logger_provider.dart';
import 'package:opentelemetry/src/api/logs/noop/noop_logger.dart';

class NoopLoggerProvider implements LoggerProvider {
  static final _noopLogger = NoopLogger();

  @override
  Logger getLogger(String name,
      {String? version = '',
      String? schemaUrl = '',
      List<Attribute> attributes = const []}) {
    return _noopLogger;
  }
    
}