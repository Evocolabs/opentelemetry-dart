import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class BatchLogRecordProcessor implements sdk.LogRecordProcessor {
  //Todo: Handle timeout
  static const int _DEFAULT_MAXIMUM_QUEUE_SIZE = 2048;
  static const int _DEFAULT_MAXIMUM_BATCH_SIZE = 512;
  static const int _DEFAULT_SCHEDULED_DELAY_MILLIS = 1000;
  static const int _DEFAULT_EXPORT_TIMEOUT_MILLIS = 30000;

  final Logger _logger = Logger('opentelemetry.BatchLogRecordProcessor');

  final sdk.LogRecordExporter _exporter;
  final int _maxQueueSize;
  final int _scheduledDelayMillis;
  final int _maxExportBatchSize;
  final int _exportTimeoutMillis;

  bool _shutdown = false;
  final List<sdk.LogRecordData> _logRecordBuffer = [];
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
  void forceFlush() {
    if (_shutdown) return;
    while (_logRecordBuffer.isNotEmpty) {
      _exportBatch(_timer);
    }
    _exporter.forceFlush();
  }

  @override
  void onEmit(sdk.ReadWriteLogRecord record, {api.SpanContext? spanContext}) {
    if (spanContext != null) record.spanContext = spanContext;
    _addToBuffer(record);
  }

  void _addToBuffer(sdk.ReadWriteLogRecord record) {
    if (_logRecordBuffer.length >= _maxQueueSize) {
      _logger.warning(
          'Dropping log. Exceeded maximum queue size of $_maxQueueSize');
      return;
    }
    _logRecordBuffer.add(sdk.ReadableLogRecord.convert(record));
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
  void shutDown() {
    if (_shutdown) return;
    try {
      forceFlush();
      _timer.cancel();
    } catch (e) {
      _logger.warning('Error while shutting down', e);
    }
    _shutdown = true;
    _exporter.shutDown();
  }
}
