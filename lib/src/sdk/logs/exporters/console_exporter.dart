import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';

class ConsoleExporter implements LogRecordExporter {
  var _shutdown = false;

  @override
  void export(List<LogRecordData> records) {
    if (_shutdown) {
      return;
    }
    for (final record in records) {
      print(record.toJson());
    }
  }

  @override
  void forceFlush() {
    return;
  }

  @override
  void shutDown() {
    if (_shutdown) return;
    forceFlush();
    _shutdown = true;
  }

}