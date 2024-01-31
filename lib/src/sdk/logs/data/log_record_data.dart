import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;
import 'package:opentelemetry/src/sdk/common/attributes.dart';

Map<String, dynamic> _wrapListAttrsToMap(List<Attribute> attrs) {
    final res = <String, dynamic>{};
    for (final attr in attrs) {
      res[attr.key] = attr.value;
    }
    return res;
  }

extension _AttributesRepr on Attributes {
  Map<String, dynamic> get attributesRepr {
    final res = <String, dynamic>{};
    for (final key in keys) {
      res[key] = get(key);
    }
    return res;
  }
}

extension _instrumentationScopeRepr on sdk.InstrumentationScope {
  Map<String, dynamic> get instrumentationScopeRepr {
    return {
      'name': name,
      'version': version,
      'schema_url': schemaUrl,
      'attributes': _wrapListAttrsToMap(attributes),
    };
  }
}

class LogRecordData extends api.LogRecord {
  sdk.Resource resource;
  sdk.InstrumentationScope instrumentationScope;

  @protected
  LogRecordData(
      super.timestamp,
      super.observedTimestamp,
      super.spanContext,
      super.severityNumber,
      super.severityText,
      super.body,
      super.attributes,
      this.resource,
      this.instrumentationScope);

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

  LogRecordData.copy(LogRecordData logRecordData): this(
    logRecordData.timestamp,
    logRecordData.observedTimestamp,
    logRecordData.spanContext,
    logRecordData.severityNumber,
    logRecordData.severityText,
    logRecordData.body,
    logRecordData.attributes,
    logRecordData.resource,
    logRecordData.instrumentationScope
  );



  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'observedTimestamp': observedTimestamp,
      'traceId': spanContext.traceId,
      'spanId': spanContext.spanId,
      'traceFlags': spanContext.traceFlags,
      'severityNumber': severityNumber,
      'severityText': severityText,
      'body': body,
      'attributes': _wrapListAttrsToMap(attributes),
      'resource': resource.attributes.attributesRepr,
      'instrumentationScope': instrumentationScope.instrumentationScopeRepr,
    };
  }
}




