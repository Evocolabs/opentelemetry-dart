@TestOn('vm')
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/simple_processor.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

void main() {
  late SimpleLogRecordProcessor simpleLogRecordProcessor;
  late MockLogRecordExporter mockLogRecordExporter;
  late ReadWriteLogRecord logRecord1, logRecord2, logRecord3;

  setUp(() {
    logRecord1 = MockReadWriteLogRecord();
    logRecord2 = MockReadWriteLogRecord();
    logRecord3 = MockReadWriteLogRecord();
    mockLogRecordExporter = MockLogRecordExporter();
    simpleLogRecordProcessor = SimpleLogRecordProcessor(mockLogRecordExporter);
  });

  tearDown(() {
    simpleLogRecordProcessor.shutDown();
    reset(mockLogRecordExporter);
  });

  test('export', () {
    simpleLogRecordProcessor
      ..onEmit(logRecord1)
      ..onEmit(logRecord2)
      ..onEmit(logRecord3);

    verify(mockLogRecordExporter.export(argThat(isA<List>().having(
            (p0) => p0.length, 'export record length should be 1', equals(1)))))
        .called(3);
  });

  test('shutdown shuts exporter down', () {
    simpleLogRecordProcessor.shutDown();

    verify(mockLogRecordExporter.shutDown()).called(1);
    verify(mockLogRecordExporter.forceFlush()).called(1);
  });
}
