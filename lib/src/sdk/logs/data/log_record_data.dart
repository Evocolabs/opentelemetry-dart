import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_api.dart' as api;
import 'package:opentelemetry/src/sdk/common/attributes.dart';
import 'package:opentelemetry/src/sdk/logs/log_record_limits.dart';

Attributes _convertListAttrs(List<api.Attribute> attrs) {
  return Attributes.empty()..addAll(attrs);
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

extension _InstrumentationScopeRepr on sdk.InstrumentationScope {
  Map<String, dynamic> get instrumentationScopeRepr {
    return {
      'name': name,
      'version': version,
      'schema_url': schemaUrl,
      'attributes': _convertListAttrs(attributes).attributesRepr,
    };
  }
}

class LogRecordData extends api.LogRecord {
  /// The limits to be applied to the log record.
  LogRecordLimits limits;

  /// The resource associated with the log record.
  sdk.Resource resource;
  
  /// The instrumentation scope associated with the log record.
  sdk.InstrumentationScope instrumentationScope;
  int _droppedAttributes = 0;

  /// The number of attributes that were dropped from the log record.
  int get droppedAttributes => _droppedAttributes;

  /// The attributes of type [Attributes] associated with the log record.
  Attributes get attributesCollection => _convertListAttrs(attributes);

  @override
  set attributes(List<api.Attribute> value) {
    attributes.clear();
    value.forEach(addAttribute);
  }

  @protected
  LogRecordData(
      super.timestamp,
      super.observedTimestamp,
      super.spanContext,
      super.severityNumber,
      super.severityText,
      super.body,
      super.attributes,
      this.limits,
      this.resource,
      this.instrumentationScope);

  LogRecordData.from(sdk.Resource resource,
      sdk.InstrumentationScope instrumentationScope, api.LogRecord logRecord)
      : this(
            logRecord.timestamp,
            logRecord.observedTimestamp,
            logRecord.spanContext,
            logRecord.severityNumber,
            logRecord.severityText,
            logRecord.body,
            logRecord.attributes,
            LogRecordLimits.unset(),
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
    logRecordData.limits,
    logRecordData.resource,
    logRecordData.instrumentationScope
  );

  /// Returns a new [LogRecordData] with the same data as this one, but with the
  /// provided [limits].
  LogRecordData withLimits(LogRecordLimits limits) {
    this.limits = limits;
    return LogRecordData.copy(this);
  }

  @override
  void addAttribute(api.Attribute attr) {
    if (limits.attributeCountLimit != -1 && attributes.length >= limits.attributeCountLimit) {
      _droppedAttributes++;
      return;
    }
    attributes.add(limits.applyValueLengthLimit(attr));
  }


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
      'attributes': attributesCollection.attributesRepr,
      'resource': resource.attributes.attributesRepr,
      'instrumentationScope': instrumentationScope.instrumentationScopeRepr,
      'droppedAttributes': _droppedAttributes,
    };
  }
}



