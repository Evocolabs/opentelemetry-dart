import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:opentelemetry/src/api/trace/span_context.dart';
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/data/readable_log_record.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_processors/log_record_processor.dart';
import 'package:opentelemetry/src/sdk/logs/data/read_write_log_record.dart';

class BatchLogRecordProcessor implements LogRecordProcessor {
  //Todo: Handle timeout
  static const int _DEFAULT_MAXIMUM_QUEUE_SIZE = 2048;
  static const int _DEFAULT_MAXIMUM_BATCH_SIZE = 512;
  static const int _DEFAULT_SCHEDULED_DELAY_MILLIS = 1000;
  static const int _DEFAULT_EXPORT_TIMEOUT_MILLIS = 30000;

  final Logger _log = Logger('opentelemetry.BatchLogRecordProcessor');

  final LogRecordExporter _exporter;
  final int _maxQueueSize;
  final int _scheduledDelayMillis;
  final int _maxExportBatchSize;
  final int _exportTimeoutMillis;

  bool _shutdown = false;
  final List<LogRecordData> _logRecordBuffer = [];
  late final Timer _timer;

  BatchLogRecordProcessor(this._exporter,
      {int exportTimeoutMillis = _DEFAULT_EXPORT_TIMEOUT_MILLIS,
      int maxExportBatchSize = _DEFAULT_MAXIMUM_BATCH_SIZE,
      int maxQueueSize = _DEFAULT_MAXIMUM_QUEUE_SIZE,
      int scheduledDelayMillis = _DEFAULT_SCHEDULED_DELAY_MILLIS})
      : _maxQueueSize = maxQueueSize,
        _maxExportBatchSize = maxExportBatchSize,
        _scheduledDelayMillis = scheduledDelayMillis,
        _exportTimeoutMillis = exportTimeoutMillis {
    _timer = Timer.periodic(
        Duration(milliseconds: _scheduledDelayMillis), _exportBatch);
  }

  @override
  bool forceFlush() {
    if (_shutdown) return false;
    while (_logRecordBuffer.isNotEmpty) {
      _exportBatch(_timer);
    }
    return _exporter.forceFlush();
  }

  @override
  void onEmit(ReadWriteLogRecord record, {SpanContext? spanContext}) {
    if (spanContext != null) record.spanContext = spanContext;
    _addToBuffer(record);
  }

  void _addToBuffer(ReadWriteLogRecord record) {
    if (_logRecordBuffer.length >= _maxQueueSize) {
      _log.warning(
          'Dropping log. Exceeded maximum queue size of $_maxQueueSize');
      return;
    }
    _logRecordBuffer.add(ReadableLogRecord.convert(record));
  }

  void _exportBatch(Timer timer) {
    if (_logRecordBuffer.isEmpty) {
      return;
    }
    final batchSize = min(_maxExportBatchSize, _logRecordBuffer.length);
    final batch = _logRecordBuffer.sublist(0, batchSize);
    _logRecordBuffer.removeRange(0, batchSize);
    _exporter.export(batch);
  }

  @override
  bool shutDown() {
    if (_shutdown) return false;
    forceFlush();
    _shutdown = true;
    _timer.cancel();
    return _exporter.shutDown();
  }
}
