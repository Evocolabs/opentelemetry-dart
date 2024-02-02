// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:http/http.dart' as http;
import '../../proto/opentelemetry/proto/collector/logs/v1/logs_service.pb.dart'
    as pb_logs_service;
import '../../proto/opentelemetry/proto/common/v1/common.pb.dart' as pb_common;
import '../../proto/opentelemetry/proto/resource/v1/resource.pb.dart'
    as pb_resource;
import '../../proto/opentelemetry/proto/logs/v1/logs.pb.dart' as pb_logs;

class CollectorExporter implements LogRecordExporter {
  final Uri uri;
  final http.Client client;
  final Map<String, String> headers;
  var _shutdown = false;

  CollectorExporter(this.uri,
      {http.Client? httpClient, this.headers = const {}})
      : client = httpClient ?? http.Client();

  @override
  void export(List<LogRecordData> logRecordData) {
    if (_shutdown) {
      return;
    }

    if (logRecordData.isEmpty) {
      return;
    }

    final body = pb_logs_service.ExportLogsServiceRequest(
        resourceLogs: _logRecordsToProtobuf(logRecordData));

    final headers = {'Content-Type': 'application/x-protobuf'}
      ..addAll(this.headers);

    client.post(uri, body: body.writeToBuffer(), headers: headers).then((value) => print(value.statusCode));
  }

  @override
  bool forceFlush() {
    return true;
  }

  @override
  bool shutDown() {
    _shutdown = true;
    client.close();
    return true;
  }

  Iterable<pb_logs.ResourceLogs> _logRecordsToProtobuf(
      List<LogRecordData> logRecordData) {
    // use a map of maps to group log records by resource and instrumentation library
    final rlm =
        <Resource, Map<InstrumentationScope, List<pb_logs.LogRecord>>>{};

    for (final l in logRecordData) {
      final _scopeLogs =
          rlm[l.resource] ?? <InstrumentationScope, List<pb_logs.LogRecord>>{};
      _scopeLogs[l.instrumentationScope] =
          _scopeLogs[l.instrumentationScope] ?? <pb_logs.LogRecord>[]
            ..add(_logRecordToProtobuf(l));
      rlm[l.resource] = _scopeLogs;
    }

    return rlm.entries.map((i) => pb_logs.ResourceLogs(
        resource: _resourceToProtobuf(i.key),
        scopeLogs: i.value.entries
            .map(
              (j) => pb_logs.ScopeLogs(
                  scope: _instrumentationScopeToProtobuf(j.key),
                  logRecords: j.value,
                  schemaUrl: j.key.schemaUrl),
            )
            .toList()));
  }

  pb_resource.Resource _resourceToProtobuf(Resource resource) {
    final attrs = <pb_common.KeyValue>[];
    for (final attr in resource.attributes.keys) {
      attrs.add(pb_common.KeyValue(
          key: attr, value: _objectToAnyValue(resource.attributes.get(attr)!)));
    }
    return pb_resource.Resource(attributes: attrs);
  }

  pb_common.InstrumentationScope _instrumentationScopeToProtobuf(
      InstrumentationScope instrumentationScope) {
    final pbInstrumentationScope = pb_common.InstrumentationScope(
        name: instrumentationScope.name,
        version: instrumentationScope.version,
        attributes: instrumentationScope.attributes.map((e) =>
            pb_common.KeyValue(key: e.key, value: _objectToAnyValue(e.value))));
    return pbInstrumentationScope;
  }

  pb_common.AnyValue _objectToAnyValue(Object value) {
    if (value is String)
      return pb_common.AnyValue(stringValue: value);
    else if (value is bool)
      return pb_common.AnyValue(boolValue: value);
    else if (value is double)
      return pb_common.AnyValue(doubleValue: value);
    else if (value is int)
      return pb_common.AnyValue(intValue: Int64(value));
    else if (value is List) {
      final list = value;
      final values = <pb_common.AnyValue>[];
      for (final v in list) {
        values.add(_objectToAnyValue(v));
      }
      return pb_common.AnyValue(
          arrayValue: pb_common.ArrayValue(values: values));
    }
    return pb_common.AnyValue();
  }

  pb_logs.LogRecord _logRecordToProtobuf(LogRecordData logRecordData) {
    final severityNumber =
        pb_logs.SeverityNumber.valueOf(logRecordData.severityNumber) ??
            pb_logs.SeverityNumber.SEVERITY_NUMBER_UNSPECIFIED;
    return pb_logs.LogRecord(
      timeUnixNano: logRecordData.timestamp,
      observedTimeUnixNano: logRecordData.observedTimestamp,
      severityNumber: severityNumber,
      severityText: logRecordData.severityText.name.toUpperCase(),
      body: _objectToAnyValue(logRecordData.body),
      attributes: logRecordData.attributes
          .map((attr) => pb_common.KeyValue(
                key: attr.key,
                value: _objectToAnyValue(attr.value),
              ))
          .toList(),
      droppedAttributesCount: logRecordData.droppedAttributes,
      flags: logRecordData.spanContext.traceFlags,
      traceId: logRecordData.spanContext.traceId.get(),
      spanId: logRecordData.spanContext.spanId.get(),
    );
  }
}
