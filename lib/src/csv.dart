part of '../table_parser.dart';

/// Read and parse CSV files
class CsvDecoder extends TableParser {
  @override
  String get mediaType => 'text/csv';
  
  @override
  String get extension => '.csv';

  final String _separator;
  final String? _textDelimiter;
  final String? _textEndDelimiter;
  final bool _shouldParseNumbers;
  final String _eol;
  late String _csvContent;

  CsvDecoder(
    this._csvContent, {
    String separator = ',',
    String? textDelimiter,
    String? textEndDelimiter,
    bool shouldParseNumbers = true,
    String eol = '\r\n',
    bool update = false,
  })  : _separator = separator,
        _textDelimiter = textDelimiter,
        _textEndDelimiter = textEndDelimiter ?? textDelimiter,
        _shouldParseNumbers = shouldParseNumbers,
        _eol = eol {
    _archive = Archive(); // Empty archive for CSV
    _update = update;
    _tables = <String, TableSheet>{};
    if (_update == true) {
      _archiveFiles = <String, ArchiveFile>{};
      _sheets = <String, XmlElement>{};
      _xmlFiles = <String, XmlDocument>{};
    }
    _parseContent();
  }

  @override
  String dumpXmlContent([String? sheet]) {
    // CSV doesn't have XML content, return the raw CSV data
    return _csvContent;
  }

  void _parseContent() {
    var table = TableSheet('Sheet1'); // CSV files have only one sheet
    _tables['Sheet1'] = table;

    if (_csvContent.trim().isEmpty) {
      return;
    }

    var lines = _csvContent.split(RegExp(r'\r?\n'));
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      var row = <dynamic>[];
      var fields = _parseCSVLine(line);
      
      for (var field in fields) {
        var value = _parseValue(field);
        row.add(value);
        _countFilledColumn(table, row, value);
      }
      
      table.rows.add(row);
      _countFilledRow(table, row);
    }

    _normalizeTable(table);
  }

  List<String> _parseCSVLine(String line) {
    var fields = <String>[];
    var current = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < line.length) {
      var char = line[i];

      if (_textDelimiter != null && char == _textDelimiter) {
        if (inQuotes) {
          // Check for escaped quotes
          if (i + 1 < line.length && line[i + 1] == _textDelimiter) {
            current.write(_textDelimiter);
            i += 2;
            continue;
          } else {
            inQuotes = false;
          }
        } else {
          inQuotes = true;
        }
      } else if (!inQuotes && char == _separator) {
        fields.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
      i++;
    }

    fields.add(current.toString());
    return fields;
  }

  dynamic _parseValue(String value) {
    // Remove text delimiters if present
    if (_textDelimiter != null && 
        value.startsWith(_textDelimiter!) && 
        value.endsWith(_textEndDelimiter!)) {
      value = value.substring(_textDelimiter!.length, 
                             value.length - _textEndDelimiter!.length);
    }

    if (!_shouldParseNumbers || value.isEmpty) {
      return value;
    }

    // Try to parse as number
    var numValue = num.tryParse(value);
    if (numValue != null) {
      return numValue;
    }

    return value;
  }

  @override
  void insertColumn(String sheet, int columnIndex) {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    if (!_tables.containsKey(sheet)) {
      throw ArgumentError("'$sheet' not found");
    }
    
    var table = _tables[sheet]!;
    if (columnIndex < 0 || columnIndex > table._maxCols) {
      throw RangeError.range(columnIndex, 0, table._maxCols);
    }

    for (var row in table.rows) {
      row.insert(columnIndex, null);
    }
    table._maxCols++;
    _regenerateCSVContent();
  }

  @override
  void removeColumn(String sheet, int columnIndex) {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    if (!_tables.containsKey(sheet)) {
      throw ArgumentError("'$sheet' not found");
    }
    
    var table = _tables[sheet]!;
    if (columnIndex < 0 || columnIndex >= table._maxCols) {
      throw RangeError.range(columnIndex, 0, table._maxCols - 1);
    }

    for (var row in table.rows) {
      row.removeAt(columnIndex);
    }
    table._maxCols--;
    _regenerateCSVContent();
  }

  @override
  void insertRow(String sheet, int rowIndex) {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    if (!_tables.containsKey(sheet)) {
      throw ArgumentError("'$sheet' not found");
    }
    
    var table = _tables[sheet]!;
    if (rowIndex < 0 || rowIndex > table._maxRows) {
      throw RangeError.range(rowIndex, 0, table._maxRows);
    }

    table.rows.insert(rowIndex, List.generate(table._maxCols, (_) => null));
    table._maxRows++;
    _regenerateCSVContent();
  }

  @override
  void removeRow(String sheet, int rowIndex) {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    if (!_tables.containsKey(sheet)) {
      throw ArgumentError("'$sheet' not found");
    }
    
    var table = _tables[sheet]!;
    if (rowIndex < 0 || rowIndex >= table._maxRows) {
      throw RangeError.range(rowIndex, 0, table._maxRows - 1);
    }

    table.rows.removeAt(rowIndex);
    table._maxRows--;
    _regenerateCSVContent();
  }

  @override
  void updateCell(String sheet, int columnIndex, int rowIndex, dynamic value) {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    if (!_tables.containsKey(sheet)) {
      throw ArgumentError("'$sheet' not found");
    }
    
    var table = _tables[sheet]!;
    if (columnIndex < 0 || columnIndex >= table._maxCols) {
      throw RangeError.range(columnIndex, 0, table._maxCols - 1);
    }
    if (rowIndex < 0 || rowIndex >= table._maxRows) {
      throw RangeError.range(rowIndex, 0, table._maxRows - 1);
    }

    table.rows[rowIndex][columnIndex] = value.toString();
    _regenerateCSVContent();
  }

  void _regenerateCSVContent() {
    if (!_update) return;

    var table = _tables['Sheet1'];
    if (table == null) return;

    var buffer = StringBuffer();
    for (var i = 0; i < table.rows.length; i++) {
      var row = table.rows[i];
      for (var j = 0; j < row.length; j++) {
        if (j > 0) buffer.write(_separator);
        
        var value = row[j]?.toString() ?? '';
        
        // Add text delimiters if needed
        if (_textDelimiter != null && 
            (value.contains(_separator) || 
             value.contains('\n') || 
             value.contains('\r') ||
             value.contains(_textDelimiter!))) {
          value = value.replaceAll(_textDelimiter!, 
                                  _textDelimiter! + _textDelimiter!);
          buffer.write(_textDelimiter! + value + _textEndDelimiter!);
        } else {
          buffer.write(value);
        }
      }
      if (i < table.rows.length - 1) {
        buffer.write(_eol);
      }
    }
    _csvContent = buffer.toString();
  }

  @override
  List<int> encode() {
    if (_update != true) {
      throw ArgumentError("'update' should be set to 'true' on constructor");
    }
    return utf8.encode(_csvContent);
  }

  @override
  String dataUrl() {
    var buffer = StringBuffer();
    buffer.write('data:$mediaType;base64,');
    buffer.write(base64Encode(encode()));
    return buffer.toString();
  }
}
