@TestOn('browser')
library html_test;

import 'package:test/test.dart';
import 'common.dart';

void main() {
  testUnsupported();
  testOds();
  testXlsx();
  testCsv();
  testUpdateOds();
  testUpdateXlsx();
}
