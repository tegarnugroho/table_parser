@TestOn('browser')

library table_parser_test;

import 'dart:convert';
import 'package:table_parser/table_parser.dart';
import 'package:test/test.dart';

import 'common_html.dart';
part 'common.dart';

void main() {
  testUnsupported();
  testOds();
  testXlsx();
  testCsv();
  testUpdateOds();
  testUpdateXlsx();
}
