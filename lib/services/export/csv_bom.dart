import 'dart:convert';
import 'dart:typed_data';

/// UTF-8 byte-order mark (03_TECHNICAL_SPEC.md, section 10.1: "Кодировка
/// UTF-8 с BOM (для корректного открытия в Excel/Sheets)") -- applied to
/// CSV files only. `manifest.json` is plain UTF-8 without a BOM: it's
/// never opened in a spreadsheet app, and a BOM can trip up some JSON
/// parsers that don't expect one.
Uint8List utf8BytesWithBom(String content) {
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(content)]);
}
