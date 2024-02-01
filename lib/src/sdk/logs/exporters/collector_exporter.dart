import 'package:opentelemetry/src/sdk/logs/data/log_record_data.dart';
import 'package:opentelemetry/src/sdk/logs/exporters/log_record_exporter.dart';
import 'package:http/http.dart' as http;

abstract class CollectorExporter implements LogRecordExporter {
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

    final body = logRecordData;
    final headers = {'Content-Type': 'application/x-protobuf'}
      ..addAll(this.headers);

    client.post(uri, body: body, headers: headers);
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
}
