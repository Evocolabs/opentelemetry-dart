import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class ConsoleExporter implements sdk.LogRecordExporter {
  var _shutdown = false;

  @override
  void export(List<sdk.LogRecordData> records) {
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
