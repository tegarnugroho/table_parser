import 'dart:io';
import 'package:path/path.dart';
import 'package:table_parser/table_parser.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Table Parser - Dump Content Tool');
    print('Extended version of spreadsheet_decoder\n');
    print(
        'Usage: dart run bin/dump_content.dart <file_path> [sheet_name] [options]');
    print('');
    print('Supported formats: CSV, ODS, XLSX');
    print('');
    print('Options for CSV:');
    print('  --separator=<char>     Custom separator (default: ,)');
    print(
        '  --delimiter=<char>     Text delimiter for quoted fields (default: none)');
    print('  --no-parse-numbers     Disable automatic number parsing');
    print('');
    print('Examples:');
    print('  dart run bin/dump_content.dart data.xlsx');
    print(
        '  dart run bin/dump_content.dart data.csv --separator=; --delimiter="');
    print('  dart run bin/dump_content.dart data.ods Sheet1');
    exit(1);
  }

  var path = args[0];
  var sheet = args.length > 1 && !args[1].startsWith('--') ? args[1] : null;

  // Parse options
  var separator = ',';
  String? textDelimiter;
  var shouldParseNumbers = true;

  for (var arg in args) {
    if (arg.startsWith('--separator=')) {
      separator = arg.substring('--separator='.length);
    } else if (arg.startsWith('--delimiter=')) {
      textDelimiter = arg.substring('--delimiter='.length);
    } else if (arg == '--no-parse-numbers') {
      shouldParseNumbers = false;
    }
  }

  if (!File(path).existsSync()) {
    print('Error: File "$path" does not exist');
    exit(1);
  }

  try {
    TableParser decoder;
    var fileExtension = extension(path).toLowerCase();

    if (fileExtension == '.csv') {
      var content = File(path).readAsStringSync();
      decoder = TableParser.decodeCsv(
        content,
        separator: separator,
        textDelimiter: textDelimiter,
        shouldParseNumbers: shouldParseNumbers,
        update: true,
      );
      print('=== CSV File: $path ===');
      if (separator != ',') print('Using separator: "$separator"');
      if (textDelimiter != null) {
        print('Using text delimiter: "$textDelimiter"');
      }
      if (!shouldParseNumbers) print('Number parsing disabled');
    } else {
      var data = File(path).readAsBytesSync();
      decoder = TableParser.decodeBytes(data, update: true);
      print('=== ${fileExtension.toUpperCase()} File: $path ===');
    }

    print('');

    if (sheet != null) {
      if (decoder.tables.containsKey(sheet)) {
        print('=== Content of sheet "$sheet" ===');
        _printTable(decoder.tables[sheet]!);
      } else {
        print('Error: Sheet "$sheet" not found');
        print('Available sheets: ${decoder.tables.keys.join(', ')}');
        exit(1);
      }
    } else {
      print('=== All sheets content ===');
      for (var sheetName in decoder.tables.keys) {
        print('\n--- Sheet: $sheetName ---');
        _printTable(decoder.tables[sheetName]!);
      }
    }

    // Show summary
    print('\n=== Summary ===');
    print('Total sheets: ${decoder.tables.length}');
    for (var entry in decoder.tables.entries) {
      var table = entry.value;
      print('${entry.key}: ${table.maxRows} rows × ${table.maxCols} columns');
    }
  } catch (e) {
    print('Error processing file: $e');
    exit(1);
  }
}

void _printTable(TableSheet table) {
  print('Dimensions: ${table.maxRows} rows × ${table.maxCols} columns');

  if (table.maxRows == 0) {
    print('(Empty table)');
    return;
  }

  // Show first 10 rows or all if less than 10
  var rowsToShow = table.maxRows > 10 ? 10 : table.maxRows;

  for (int i = 0; i < rowsToShow; i++) {
    var row = table.rows[i];
    var rowStr = row.map((cell) {
      if (cell == null) return '<null>';
      if (cell is String && cell.isEmpty) return '<empty>';
      return cell.toString();
    }).join(' | ');
    print('Row ${i.toString().padLeft(2)}: $rowStr');
  }

  if (table.maxRows > 10) {
    print('... (${table.maxRows - 10} more rows)');
  }
}
