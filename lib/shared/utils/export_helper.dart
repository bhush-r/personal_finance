import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ExportHelper {
  static Future<String> saveCSVFile(String csvData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final file = File('${directory.path}/transactions_$timestamp.csv');

      await file.writeAsString(csvData);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save CSV file: $e');
    }
  }

  static Future<String> saveJSONFile(String jsonData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final file = File('${directory.path}/transactions_$timestamp.json');

      await file.writeAsString(jsonData);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save JSON file: $e');
    }
  }

  static Future<void> shareFile(String filePath) async {
    // TODO: Implement file sharing using share_plus package
    // Example:
    // await Share.shareFiles([filePath]);
  }

  static String transactionsToJSON(dynamic transactions) {
    final List<Map<String, dynamic>> data = transactions.map((txn) {
      return {
        'id': txn.id,
        'date': txn.date.toIso8601String(),
        'amount': txn.amount,
        'type': txn.type.name,
        'category': txn.category.name,
        'note': txn.note,
      };
    }).toList();

    return _prettyPrintJSON(data);
  }

  static String _prettyPrintJSON(dynamic json) {
    return _JsonEncoder().convert(json);
  }

  static String transactionsToCSV(dynamic transactions) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Amount,Type,Category,Note');

    for (final txn in transactions) {
      final date = txn.date.toIso8601String();
      final amount = txn.amount;
      final type = txn.type.name;
      final category = txn.category.name;
      final note = txn.note ?? '';

      buffer.writeln('$date,$amount,$type,$category,$note');
    }

    return buffer.toString();
  }
}

/// ✅ FIXED: Simple JSON encoder (not extending anything)
class _JsonEncoder {
  static const String _indent = '  ';

  String convert(Object? input) {
    return _encode(input, 0);
  }

  String _encode(Object? object, int indentLevel) {
    if (object == null) return 'null';
    if (object is bool) return object.toString();
    if (object is num) return object.toString();
    if (object is String) return '"$object"';

    if (object is List) {
      return _encodeList(object, indentLevel);
    }

    if (object is Map) {
      return _encodeMap(object, indentLevel);
    }

    return object.toString();
  }

  String _encodeList(List<dynamic> list, int indentLevel) {
    if (list.isEmpty) return '[]';

    final buffer = StringBuffer('[\n');
    final innerIndent = _indent * (indentLevel + 1);

    for (int i = 0; i < list.length; i++) {
      buffer.write(innerIndent);
      buffer.write(_encode(list[i], indentLevel + 1));
      if (i < list.length - 1) buffer.write(',');
      buffer.write('\n');
    }

    buffer.write(_indent * indentLevel);
    buffer.write(']');
    return buffer.toString();
  }

  String _encodeMap(Map<dynamic, dynamic> map, int indentLevel) {
    if (map.isEmpty) return '{}';

    final buffer = StringBuffer('{\n');
    final innerIndent = _indent * (indentLevel + 1);
    final keys = map.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      buffer.write(innerIndent);
      buffer.write('"${keys[i]}": ');
      buffer.write(_encode(map[keys[i]], indentLevel + 1));
      if (i < keys.length - 1) buffer.write(',');
      buffer.write('\n');
    }

    buffer.write(_indent * indentLevel);
    buffer.write('}');
    return buffer.toString();
  }
}