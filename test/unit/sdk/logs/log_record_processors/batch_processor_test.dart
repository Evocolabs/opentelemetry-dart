@TestOn('vm')
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/batch_processor.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';


void main() {
  late BatchLogRecordProcessor batchLogRecordProcessor;
  late MockLogRecordExporter mockLogRecordExporter;
  late ReadWriteLogRecord logRecord1, logRecord2, logRecord3;

  setUp(() {
    logRecord1 = MockReadWriteLogRecord();
    logRecord2 = MockReadWriteLogRecord();
    logRecord3 = MockReadWriteLogRecord();
    mockLogRecordExporter = MockLogRecordExporter();
    batchLogRecordProcessor = BatchLogRecordProcessor(mockLogRecordExporter);
  });

  tearDown(() {
    batchLogRecordProcessor.shutDown();
    reset(mockLogRecordExporter);
  });

  test('forceFlush', () {
    batchLogRecordProcessor
      ..onEmit(logRecord1)
      ..onEmit(logRecord2)
      ..forceFlush()
      ..onEmit(logRecord3)
      ..forceFlush();

    verify(mockLogRecordExporter.export(argThat(
            isA<List>().having((list) => list.length, 'length', equals(2)))))
        .called(1);
    verify(mockLogRecordExporter.export(argThat(
            isA<List>().having((list) => list.length, 'length', equals(1)))));
    verify(mockLogRecordExporter.forceFlush()).called(2);
  });
  
  test('shutdown shuts exporter down', () {
    batchLogRecordProcessor.shutDown();

    verify(mockLogRecordExporter.shutDown()).called(1);
    verify(mockLogRecordExporter.forceFlush()).called(1);
  });
}
