import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';

abstract class LogRecordExporter {
  void export(List<LogRecordData> records);

  bool forceFlush();

  bool shutDown();
}