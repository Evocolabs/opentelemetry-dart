import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart' as api;

class InvalidLogRecordLimitsException implements Exception {
  final String message;

  InvalidLogRecordLimitsException(this.message);

  @override
  String toString() {
    return 'InvalidLogRecordLimitsException: $message';
  }
}

class LogRecordLimits {
  static const int _DEFAULT_ATTRIBUTE_COUNT_LIMIT = 128;
  static const int _DEFAULT_ATTRIBUTE_VALUE_LENGTH_LIMIT = -1;

  int _attributeCountLimit;
  int _attributeValueLengthLimit;
  @protected
  LogRecordLimits(this._attributeCountLimit, this._attributeValueLengthLimit);

  LogRecordLimits.unset() : this.create();

  LogRecordLimits.create(
      {attributeCountLimit = _DEFAULT_ATTRIBUTE_COUNT_LIMIT,
      attributeValueLengthLimit = _DEFAULT_ATTRIBUTE_VALUE_LENGTH_LIMIT})
      : _attributeCountLimit = attributeCountLimit,
        _attributeValueLengthLimit = attributeValueLengthLimit;

  int get attributeCountLimit => _attributeCountLimit;
  int get attributeValueLengthLimit => _attributeValueLengthLimit;

  void setAttributeCountLimit(int limit) {
    if (limit < 0) {
      throw InvalidLogRecordLimitsException(
          'Attribute count limit must be non-negative');
    }
    _attributeCountLimit = limit;
  }

  void setAttributeValueLengthLimit(int limit) {
    if (limit < -1) {
      throw InvalidLogRecordLimitsException(
          'Attribute value length limit must be non-negative or -1 for infinity');
    }
    _attributeValueLengthLimit = limit;
  }

  api.Attribute applyValueLengthLimit(api.Attribute attr) {
    final key = attr.key;
    final value = attr.value;

    if (value is String) {
      return api.Attribute.fromString(key, _applyValLenLimitOnString(value));
    }
    if (value is List<String>) {
      return api.Attribute.fromStringList(
          key, value.map(_applyValLenLimitOnString).toList());
    }
    return attr;
  }

  String _applyValLenLimitOnString(String s) {
    return s.length > _attributeValueLengthLimit
        ? s.substring(0, _attributeValueLengthLimit)
        : s;
  }
}
