import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/api/logs/logger.dart';

// A registry for creating named [Logger]s.
abstract class LoggerProvider {
  Logger getLogger(String name,
      {String version = '',
      String schemaUrl = '',
      List<api.Attribute> attributes = const []});
}
