
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';

class ReadableLogRecord extends LogRecordData {
  ReadableLogRecord.from(
      super.resource, super.instrumentationScope, super.logRecord)
      : super.from();
}