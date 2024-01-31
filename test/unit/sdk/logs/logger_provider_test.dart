@TestOn('vm')

import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/api/logs/noop/noop_logger.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

import 'package:opentelemetry/src/sdk/logs/logger_provider.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.dart';

void main() {
  group('Logger Creation', () {
    test('getLogger stores loggers by name', () {
      final loggerProvider = LoggerProvider();
      final logger1 = loggerProvider.getLogger('logger1');
      final logger2 = loggerProvider.getLogger('logger2');
      final logger1WithVersion =
          loggerProvider.getLogger('logger1', version: '1.0.0');

      expect(
          logger1,
          allOf([
            isNot(logger2),
            isNot(logger1WithVersion),
            same(loggerProvider.getLogger('logger1'))
          ]));
    });

    test('resource in loggerProvider associated with all logRecords', () {
      final processor = MockLogRecordProcessor();
      final loggerProvider = LoggerProvider(
          resource: Resource([Attribute.fromInt('testInt', 1)]),
          logRecordProcessors: [processor]);

      final logger = loggerProvider.getLogger('logger1');

      final logRecord = LogRecord.create();
      logger.emit(logRecord);

      final captured =
          verify(processor.onEmit(captureThat(isA<ReadWriteLogRecord>())))
              .captured;
      if (captured.isNotEmpty) {
        final ReadWriteLogRecord logRecord = captured.first;
        // Now you can assert things about logRecord
        expect(logRecord.resource.attributes.get('testInt'), 1);
      }
    });
  });

  group('LoggerProvider Shutdown Behavior', () {
    test('shutdown is callable only once, return noopLogger in subsequent calls', () {
      final loggerProvider = LoggerProvider();
      final logger = loggerProvider.getLogger('logger1');

      expect(loggerProvider.shutDown(), true);
      expect(loggerProvider.shutDown(), false);
      expect(logger, isNot(NoopLogger()));
      expect(loggerProvider.getLogger('logger1'), isA<NoopLogger>());
    });

    test('shutdown shuts down all registered LogRecordProcessors', () {
      final processor1 = MockLogRecordProcessor();
      final processor2 = MockLogRecordProcessor();
      final loggerProvider = LoggerProvider(
          logRecordProcessors: [processor1, processor2]);

      final isShutdown = loggerProvider.shutDown();

      expect(isShutdown, true);
      verify(processor1.shutDown()).called(1);
      verify(processor2.shutDown()).called(1);
    });

  });
}
