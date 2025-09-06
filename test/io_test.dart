@TestOn('vm')

library table_parser_test;

import 'package:test/test.dart';

import 'html_test.dart';

void main() {
  testUnsupported();
  testOds();
  testXlsx();
  testCsv();
  testUpdateOds();
  testUpdateXlsx();
}
