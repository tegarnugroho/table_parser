import 'dart:convert';
import 'dart:io';
import 'package:table_parser/table_parser.dart';

List<int> _readBytes(String filename) {
  var fullUri = Uri.file('test/files/$filename');
  return File.fromUri(fullUri).readAsBytesSync();
}

String readBase64(String filename) {
  return base64Encode(_readBytes(filename));
}

TableParser decode(String filename, {bool update = false}) {
  return TableParser.decodeBytes(_readBytes(filename),
      update: update, verify: true);
}

void save(String file, List<int> data) {
  File(file)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data);
}
