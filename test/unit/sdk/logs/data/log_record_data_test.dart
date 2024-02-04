@TestOn('vm')
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_limits.dart';
import 'package:test/test.dart';

void main() {
  LogRecordData _createLogRecordData() {
    return LogRecordData.from(Resource([]),
        InstrumentationScope('test', '1.0.0', 'url', []), LogRecord.create());
  }

  test('LogRecord add attributes', () {
    final logRecordData = _createLogRecordData()
      ..addAttribute(Attribute.fromInt('test', 1));

    expect(logRecordData.attributesCollection.get('test'), 1);
  });

  test('LogRecord add attributes with limits exceeded', () {
    final logRecordData = _createLogRecordData()
      ..withLimits(LogRecordLimits.create(
          attributeCountLimit: 3, attributeValueLengthLimit: 3))
      ..addAttribute(Attribute.fromInt('test', 1))
      ..addAttribute(Attribute.fromString('testTruncation', '1234'))
      ..addAttribute(Attribute.fromStringList(
          'testTruncationOfAttrs', ['1234', '12345', '12345']))
      ..addAttribute(Attribute.fromInt('testDiscardAttrs', 1));

    expect(logRecordData.attributesCollection.length, 3);
    expect(logRecordData.attributesCollection.get('test'), 1);
    expect(logRecordData.attributesCollection.get('testTruncation'), '123');
    expect(logRecordData.attributesCollection.get('testTruncationOfAttrs'),
        ['123', '123', '123']);
    expect(logRecordData.droppedAttributes, 1);
  });
}
