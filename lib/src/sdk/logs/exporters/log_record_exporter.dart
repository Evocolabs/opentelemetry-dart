import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

abstract class LogRecordExporter {
  void export(List<sdk.LogRecordData> records);

  void forceFlush();

  void shutDown();
}
