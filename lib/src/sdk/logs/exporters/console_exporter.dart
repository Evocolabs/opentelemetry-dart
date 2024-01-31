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
  bool forceFlush() {
    return true;
  }

  @override
  bool shutDown() {
    if (_shutdown) return false;
    forceFlush();
    _shutdown = true;
    return true;
  }

}