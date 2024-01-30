import 'package:meta/meta.dart';
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;

class LogRecordData extends api.LogRecord {
  final sdk.Resource _resource;
  final sdk.InstrumentationScope _instrumentationScope;

  @protected
  LogRecordData(
      super._timestamp,
      super._observedTimestamp,
      super._spanContext,
      super._severityNumber,
      super._severityText,
      super._body,
      super._attributes,
      this._resource,
      this._instrumentationScope);

  LogRecordData.from(sdk.Resource resource,
      sdk.InstrumentationScope instrumentationScope, LogRecord logRecord)
      : this(
            logRecord.timestamp,
            logRecord.observedTimestamp,
            logRecord.spanContext,
            logRecord.severityNumber,
            logRecord.severityText,
            logRecord.body,
            logRecord.attributes,
            resource,
            instrumentationScope);

  sdk.Resource get resource => _resource;

  sdk.InstrumentationScope get instrumentationScope => _instrumentationScope;
}




