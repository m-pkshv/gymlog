import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/export/csv_bom.dart';

void main() {
  test('prefixes the exact UTF-8 BOM bytes (EF BB BF)', () {
    final bytes = utf8BytesWithBom('a,b');
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
  });

  test('encodes the content as UTF-8 after the BOM, including non-ASCII', () {
    final bytes = utf8BytesWithBom('Ногa,5');
    expect(utf8.decode(bytes.sublist(3)), 'Ногa,5');
  });

  test('an empty string yields just the BOM', () {
    expect(utf8BytesWithBom(''), [0xEF, 0xBB, 0xBF]);
  });
}
