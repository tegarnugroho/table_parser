@TestOn('browser')
library;

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
