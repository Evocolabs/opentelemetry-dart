@TestOn('vm')
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/api/logs/noop/noop_logger_provider.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerProvider', () {
     test('LoggerProvider.get with name returns inert instance of Logger', () {
      final provider = NoopLoggerProvider();
      expect(provider, isA<api.LoggerProvider>());
      provider.getLogger('testname').emit(LogRecord());
    });
    test('LoggerProvider.get with name+version returns inert instance of Logger', () {
      final provider = NoopLoggerProvider();
      expect(provider, isA<api.LoggerProvider>());
      provider.getLogger('testname', version: 'version').emit(LogRecord());
    });

    test('LoggerProvider.get with name+version+url returns inert instance of Logger', () {
      final provider = NoopLoggerProvider();
      expect(provider, isA<api.LoggerProvider>());
      provider.getLogger('testname', version: 'version', schemaUrl: 'url').emit(LogRecord());
    });
    test(
        'LoggerProvider.get with name+version+url+attributes returns inert '
        'instance of Logger', () {
      final provider = NoopLoggerProvider();
      expect(provider, isA<api.LoggerProvider>());
      final logger = provider
          .getLogger('testname', version: 'version', schemaUrl: 'url', attributes: [
        api.Attribute.fromString('http.method', 'post'),
        api.Attribute.fromString('http.scheme', 'http')
      ]);
      logger.emit(LogRecord());
    });
  });
}