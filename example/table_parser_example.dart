import 'dart:io';
import 'package:path/path.dart';
import 'package:table_parser/table_parser.dart';

void main(List<String> args) {
  print('=== Table Parser - Comprehensive Example ===');
  print('Extended version of spreadsheet_decoder with enhanced features\n');

  // Example 1: CSV files (Basic and Advanced)
  csvExample();
  advancedCsvExample();

  // Example 2: Excel/XLSX files
  excelExample();

  // Example 3: OpenDocument Spreadsheet (ODS) files
  odsExample();

  // Example 4: Working with different data types
  dataTypesExample();

  print('=== All examples completed! ===');
}

void excelExample() {
  print('3. Excel (XLSX) File Example:');
  var file = '../test/files/test.xlsx';

  if (!File(file).existsSync()) {
    print('Excel file not found at $file');
    return;
  }

  var bytes = File(file).readAsBytesSync();
  var decoder = TableParser.decodeBytes(bytes, update: true);

  // Display sheets and their content
  for (var sheetName in decoder.tables.keys) {
    print('Sheet: $sheetName');
    var table = decoder.tables[sheetName]!;
    print('Dimensions: ${table.maxRows} rows x ${table.maxCols} columns');

    for (int i = 0; i < table.maxRows && i < 5; i++) {
      // Show first 5 rows
      print('  Row $i: ${table.rows[i]}');
    }
  }

  // Modify data
  var sheet = decoder.tables.keys.first;
  decoder
    ..updateCell(sheet, 0, 0, "Modified Header")
    ..updateCell(sheet, 1, 1, 42.5)
    ..insertRow(sheet, 1)
    ..updateCell(sheet, 0, 1, 'New Row Data');

  // Save modified file
  var outputDir = Directory('../test/out');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  File('../test/out/modified_${basename(file)}')
      .writeAsBytesSync(decoder.encode());

  print(
      'Modified Excel file saved to: ../test/out/modified_${basename(file)}\n');
}

void odsExample() {
  print('4. OpenDocument Spreadsheet (ODS) File Example:');
  var file = '../test/files/test.ods';

  if (!File(file).existsSync()) {
    print('ODS file not found at $file');
    return;
  }

  var bytes = File(file).readAsBytesSync();
  var decoder = TableParser.decodeBytes(bytes, update: true);

  for (var sheetName in decoder.tables.keys) {
    print('Sheet: $sheetName');
    var table = decoder.tables[sheetName]!;
    print('Dimensions: ${table.maxRows} rows x ${table.maxCols} columns');

    for (int i = 0; i < table.maxRows && i < 3; i++) {
      // Show first 3 rows
      print('  Row $i: ${table.rows[i]}');
    }
  }

  print('ODS file processed successfully\n');
}

void csvExample() {
  print('1. CSV File Example (Basic):');

  // Create sample CSV
  var csvContent = '''Product,Category,Price,In Stock
Laptop,Electronics,999.99,true
Mouse,Electronics,29.99,true
Book,Education,19.95,false
Desk Chair,Furniture,159.00,true''';

  var decoder = TableParser.decodeCsv(csvContent, update: true);
  var table = decoder.tables['Sheet1']!;

  print('Original CSV data:');
  for (int i = 0; i < table.maxRows; i++) {
    print('  Row $i: ${table.rows[i]}');
  }

  // Modify CSV data
  decoder
    ..updateCell('Sheet1', 2, 1, 899.99) // Update laptop price
    ..insertRow('Sheet1', table.maxRows) // Add new row at end
    ..updateCell('Sheet1', 0, table.maxRows - 1, 'Tablet')
    ..updateCell('Sheet1', 1, table.maxRows - 1, 'Electronics')
    ..updateCell('Sheet1', 2, table.maxRows - 1, 299.99)
    ..updateCell('Sheet1', 3, table.maxRows - 1, true);

  print('\nModified CSV data:');
  for (int i = 0; i < table.maxRows; i++) {
    print('  Row $i: ${table.rows[i]}');
  }

  // Save CSV
  var csvBytes = decoder.encode();
  var outputDir = Directory('../test/out');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  File('../test/out/products.csv').writeAsBytesSync(csvBytes);
  print('CSV saved to: ../test/out/products.csv\n');
}

void dataTypesExample() {
  print('5. Data Types Example:');

  var csvContent = '''Name,Age,Salary,Is Manager,Join Date
Alice,25,75000.50,true,"2023-01-15"
Bob,30,85000,false,"2022-05-20"
Charlie,35,95000.75,true,"2021-03-10"''';

  var decoder = TableParser.decodeCsv(csvContent, textDelimiter: '"');
  var table = decoder.tables['Sheet1']!;

  print('Data with various types:');
  for (int i = 0; i < table.maxRows; i++) {
    var row = table.rows[i];
    print('  Row $i: $row');
    if (i > 0) {
      // Skip header
      print('    Types: ${row.map((cell) => cell.runtimeType).toList()}');
    }
  }
  print('');
}

void advancedCsvExample() {
  print('2. Advanced CSV Parsing Features:');

  // CSV with custom separator
  print('  a) Custom separator (semicolon):');
  var csvSemicolon = '''Name;Department;Budget
Engineering Team;Development;150000
Marketing Team;Sales;80000
HR Team;Human Resources;60000''';

  var decoder1 = TableParser.decodeCsv(csvSemicolon, separator: ';');
  var table1 = decoder1.tables['Sheet1']!;
  for (int i = 0; i < table1.maxRows; i++) {
    print('    ${table1.rows[i]}');
  }

  // CSV with quoted fields containing separators
  print('\n  b) Quoted fields with embedded separators:');
  var csvQuoted = '''Name,Description,Salary
"Smith, John","Senior Developer, Team Lead",85000
"Doe, Jane","Marketing Manager, Brand Lead",75000
"Johnson, Mike","HR Director, ""People Operations""",90000''';

  var decoder2 = TableParser.decodeCsv(csvQuoted, textDelimiter: '"');
  var table2 = decoder2.tables['Sheet1']!;
  for (int i = 0; i < table2.maxRows; i++) {
    print('    ${table2.rows[i]}');
  }

  // CSV manipulation
  print('\n  c) CSV data manipulation:');
  var csvManip = '''ID,Name,Score
1,Alice,85
2,Bob,92
3,Charlie,78''';

  var decoder3 = TableParser.decodeCsv(csvManip, update: true);
  var table3 = decoder3.tables['Sheet1']!;

  print('    Original data:');
  for (int i = 0; i < table3.maxRows; i++) {
    print('      ${table3.rows[i]}');
  }

  // Insert new row first
  decoder3.insertRow('Sheet1', 1);
  decoder3.updateCell('Sheet1', 0, 1, 4);
  decoder3.updateCell('Sheet1', 1, 1, 'Diana');
  decoder3.updateCell('Sheet1', 2, 1, 95);

  // Insert new column by extending rows
  decoder3.insertColumn('Sheet1', 3);
  decoder3.updateCell('Sheet1', 3, 0, 'Grade');
  decoder3.updateCell('Sheet1', 3, 1, 'A');
  decoder3.updateCell('Sheet1', 3, 2, 'B+');
  decoder3.updateCell('Sheet1', 3, 3, 'A-');
  decoder3.updateCell('Sheet1', 3, 4, 'C+');

  print('\n    Modified data:');
  for (int i = 0; i < table3.maxRows; i++) {
    print('      ${table3.rows[i]}');
  }

  print('');
}
