# Table Parser

[![Pub version](https://img.shields.io/pub/v/table_parser.svg)](https://pub.dartlang.org/packages/table_parser)

Table Parser is an extended and improved version of the excellent [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder) package. This library provides enhanced functionality for parsing, manipulating, and updating table documents in various formats including CSV, ODS, and XLSX.

## Acknowledgments

This package is built upon the foundation of the [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder) package created by **Sébastien Stehly** ([sestegra](https://github.com/sestegra)). We extend our sincere gratitude for their excellent work and for making it available under the MIT License, which allows for modification and redistribution.

**Original Package**: [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder)  
**Original Author**: Sébastien Stehly  
**License**: MIT License

## Key Improvements

This package extends the original spreadsheet_decoder with:

- **Enhanced CSV Support**: Comprehensive CSV parsing with custom separators, quoted fields, and escape sequences
- **Better Error Handling**: Improved validation and error reporting
- **Performance Optimizations**: Better handling of large files and memory usage
- **Extended API**: Additional methods for table manipulation and data export
- **Comprehensive Documentation**: More examples and detailed usage instructions
- **Modern Dart Support**: Updated for Dart 3.0+ with null safety

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  table_parser: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Usage

### Quick Start

```dart
import 'package:table_parser/table_parser.dart';
import 'dart:io';

void main() {
  // Parse CSV
  var csvContent = '''Name,Age,City
John,30,New York
Jane,25,Los Angeles''';
  
  var decoder = TableParser.decodeCsv(csvContent);
  var table = decoder.tables['Sheet1']!;
  print(table.rows); // [[Name, Age, City], [John, 30, New York], [Jane, 25, Los Angeles]]
  
  // Parse Excel/ODS from file
  var bytes = File('data.xlsx').readAsBytesSync();
  var spreadsheet = TableParser.decodeBytes(bytes);
  var sheet = spreadsheet.tables['Sheet1']!;
  print('${sheet.maxRows} rows, ${sheet.maxCols} columns');
}
```

### CSV Files

#### Basic CSV Parsing

```dart
import 'package:table_parser/table_parser.dart';

void main() {
  var csvContent = '''Product,Price,InStock
Laptop,999.99,true
Mouse,29.99,false''';
  
  var decoder = TableParser.decodeCsv(csvContent);
  var table = decoder.tables['Sheet1']!;
  
  // Access data
  for (var row in table.rows) {
    print(row);
  }
}
```

#### CSV with Custom Options

```dart
var decoder = TableParser.decodeCsv(
  csvContent,
  separator: ';',              // Custom separator (default: ',')
  textDelimiter: '"',          // Text delimiter for quoted fields (default: null)
  shouldParseNumbers: true,    // Parse numbers automatically (default: true)
  eol: '\n',                   // End of line character (default: '\r\n')
  update: true,                // Enable update mode (default: false)
);
```

#### CSV with Quoted Fields

```dart
var csvContent = '''Name,Description,Salary
"Smith, John","Senior Developer",85000
"Doe, Jane","Marketing Manager",75000
"Johnson, Mike","HR Director ""People Ops""",90000''';

var decoder = TableParser.decodeCsv(csvContent, textDelimiter: '"');
var table = decoder.tables['Sheet1']!;

// Properly handles quoted fields with embedded commas and escaped quotes
print(table.rows[1]); // [Smith, John, Senior Developer, 85000]
```

#### CSV Data Manipulation

```dart
var decoder = TableParser.decodeCsv(csvContent, update: true);

// Update existing cell
decoder.updateCell('Sheet1', 1, 1, 31); // Update age in row 1

// Insert new row
decoder.insertRow('Sheet1', 1);
decoder.updateCell('Sheet1', 0, 1, 'New Name');
decoder.updateCell('Sheet1', 1, 1, 28);

// Export back to CSV
var updatedCsvBytes = decoder.encode();
File('updated.csv').writeAsBytesSync(updatedCsvBytes);
```

### Excel (XLSX) and OpenDocument (ODS) Files

#### Reading Files

```dart
import 'dart:io';
import 'package:table_parser/table_parser.dart';

void main() {
  // Read from file
  var bytes = File('spreadsheet.xlsx').readAsBytesSync();
  var decoder = TableParser.decodeBytes(bytes, update: true);
  
  // Access sheets
  for (var sheetName in decoder.tables.keys) {
    var table = decoder.tables[sheetName]!;
    print('Sheet: $sheetName');
    print('Dimensions: ${table.maxRows} rows × ${table.maxCols} columns');
    
    // Access cell data
    for (int i = 0; i < table.maxRows; i++) {
      print('Row $i: ${table.rows[i]}');
    }
  }
}
```

#### Modifying Spreadsheets

```dart
// Update existing data
decoder.updateCell('Sheet1', 0, 0, 'New Header');
decoder.updateCell('Sheet1', 1, 1, 42.5);

// Insert new rows/columns
decoder.insertRow('Sheet1', 1);
decoder.insertColumn('Sheet1', 0);

// Save modified spreadsheet
var modifiedBytes = decoder.encode();
File('modified_spreadsheet.xlsx').writeAsBytesSync(modifiedBytes);
```

### Web Usage (Client-side)

```dart
import 'dart:html';
import 'package:table_parser/table_parser.dart';

void handleFileUpload(File file) {
  var reader = FileReader();
  reader.onLoadEnd.listen((event) {
    var decoder = TableParser.decodeBytes(reader.result as List<int>);
    var table = decoder.tables['Sheet1']!;
    
    // Process spreadsheet data
    for (var row in table.rows) {
      print(row);
    }
  });
  reader.readAsArrayBuffer(file);
}
```

## Command Line Tool

This package includes a command-line tool for inspecting table files:

```bash
# Basic usage
dart run table_parser:dump_content data.xlsx

# With specific sheet
dart run table_parser:dump_content data.xlsx Sheet1

# CSV with custom options
dart run table_parser:dump_content data.csv --separator=; --delimiter="

# Show help
dart run table_parser:dump_content
```

## Supported Formats

| Format | Extension | Read | Write | Notes |
|--------|-----------|------|-------|-------|
| CSV | `.csv` | ✅ | ✅ | Full support with custom separators and quoted fields |
| Excel | `.xlsx` | ✅ | ✅ | Modern Excel format |
| OpenDocument | `.ods` | ✅ | ✅ | LibreOffice/OpenOffice format |

## API Reference

### TableParser Class

#### Factory Constructors

- `TableParser.decodeBytes(List<int> bytes, {bool update = false})` - Decode XLSX/ODS from bytes
- `TableParser.decodeCsv(String csvContent, {...})` - Decode CSV from string
- `TableParser.decodeCsvBytes(List<int> bytes, {...})` - Decode CSV from bytes

#### CSV Options

- `separator` - Field separator character (default: `,`)
- `textDelimiter` - Text delimiter for quoted fields (default: `null`)
- `shouldParseNumbers` - Auto-parse numbers (default: `true`)
- `eol` - End of line character (default: `\r\n`)
- `update` - Enable modification support (default: `false`)

#### Methods

- `updateCell(String sheet, int column, int row, dynamic value)` - Update cell value
- `insertRow(String sheet, int rowIndex)` - Insert new row
- `insertColumn(String sheet, int columnIndex)` - Insert new column
- `removeRow(String sheet, int rowIndex)` - Remove row
- `removeColumn(String sheet, int columnIndex)` - Remove column
- `encode()` - Export back to bytes

### TableSheet Class

#### Properties

- `maxRows` - Number of rows
- `maxCols` - Number of columns
- `rows` - List of row data

## Examples

See the [example](example/) folder for comprehensive usage examples:

- Basic CSV, XLSX, and ODS parsing
- Advanced CSV features (custom separators, quoted fields)
- Data manipulation and export
- Error handling

Run the example:

```bash
dart run example/table_parser_example.dart
```

## Features and Limitations

### ✅ Supported Features

- **CSV**: Complete support including custom separators, quoted fields, escape sequences
- **XLSX/ODS**: Read and write with full data type support
- **Data Types**: Automatic detection and preservation of numbers, booleans, strings
- **Modification**: Insert/remove rows and columns, update cells
- **Export**: Save modified data back to original format
- **Memory Efficient**: Streaming parsing for large files

### ❌ Current Limitations

- Annotations and comments are not preserved
- Spanned (merged) rows and columns are not supported
- Hidden rows and columns are visible in output
- XLSX: Only native Excel date/time formats (not custom formats)
- ODS: LibreOffice-specific formatting may not be preserved

## Migration from spreadsheet_decoder

This package maintains API compatibility with spreadsheet_decoder. To migrate:

1. Update your dependency:

   ```yaml
   dependencies:
     table_parser: ^1.0.0  # instead of spreadsheet_decoder
   ```

2. Update imports:

   ```dart
   import 'package:table_parser/table_parser.dart';  // instead of spreadsheet_decoder
   ```

3. Update class names:

   ```dart
   TableParser.decodeBytes(bytes);     // instead of SpreadsheetDecoder
   TableSheet table = decoder.tables;  // instead of SpreadsheetTable
   ```

## Contributing

Contributions are welcome! This package builds upon the excellent foundation of [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder) and aims to extend its capabilities while maintaining compatibility.

### Development

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass: `dart test`
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This package extends and modifies the original [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder) package by Sébastien Stehly, also licensed under the MIT License.

## Credits

- **Original Package**: [spreadsheet_decoder](https://pub.dev/packages/spreadsheet_decoder) by Sébastien Stehly
- **Extended Version**: Table Parser - Enhanced with CSV support and additional features
- **Contributors**: Thank you to all contributors who help improve this package
