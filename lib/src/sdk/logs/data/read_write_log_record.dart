import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class ReadWriteLogRecord extends sdk.LogRecordData {
  ReadWriteLogRecord.from(sdk.Resource resource,
      sdk.InstrumentationScope instrumentationScope, api.LogRecord logRecord)
      : super.from(resource, instrumentationScope, logRecord);

  ReadWriteLogRecord.convert(sdk.LogRecordData logRecordData)
      : super.copy(logRecordData);
}
