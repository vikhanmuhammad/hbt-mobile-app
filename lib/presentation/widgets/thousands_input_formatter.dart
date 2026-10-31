import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Live thousand-separator formatter for an amount `TextField` (e.g. Budget
/// Tracker's budget/amount inputs) — reformats the field's text as the user
/// types so groups of 3 digits get a `.` separator (`id_ID`), while keeping
/// the cursor at the same logical digit position instead of jumping to the
/// end.
///
/// With [decimalDigits] 0 (IDR) only digits are meaningful input. With
/// [decimalDigits] > 0 (SGD/USD/...) a `,` starts the cents part — a `.`
/// typed by the user is taken as that comma too, since `.` is the grouping
/// separator here and many keyboards only offer `.` (feedback 8, slide 8).
/// Use [parse] to read the amount back, in the currency's smallest unit.
class ThousandsInputFormatter extends TextInputFormatter {
  ThousandsInputFormatter({this.decimalDigits = 0}) : _format = NumberFormat.decimalPattern('id_ID');

  final int decimalDigits;
  final NumberFormat _format;

  static final _nonDigit = RegExp(r'[^0-9]');

  /// The amount in [formatted], in smallest units — e.g. "5,50" -> 550 with
  /// [decimalDigits] 2, "50.000" -> 50000 with [decimalDigits] 0.
  static int parse(String formatted, {int decimalDigits = 0}) {
    if (decimalDigits == 0) {
      final digitsOnly = formatted.replaceAll(_nonDigit, '');
      return digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
    }
    final comma = formatted.indexOf(',');
    final wholeText = (comma < 0 ? formatted : formatted.substring(0, comma)).replaceAll(_nonDigit, '');
    var fraction = comma < 0 ? '' : formatted.substring(comma + 1).replaceAll(_nonDigit, '');
    if (fraction.length > decimalDigits) fraction = fraction.substring(0, decimalDigits);
    fraction = fraction.padRight(decimalDigits, '0');
    final whole = wholeText.isEmpty ? 0 : int.parse(wholeText);
    var factor = 1;
    for (var i = 0; i < decimalDigits; i++) {
      factor *= 10;
    }
    return whole * factor + int.parse(fraction);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    var cursor = newValue.selection.end.clamp(0, text.length);

    if (decimalDigits > 0) {
      // A single `.` just typed means "decimal point", not grouping.
      final typedOne = text.length == oldValue.text.length + 1 && cursor > 0;
      if (typedOne && text[cursor - 1] == '.') {
        text = '${text.substring(0, cursor - 1)},${text.substring(cursor)}';
      }
    }

    // Significant characters: digits, plus the first comma when decimals
    // are allowed. Everything else (grouping dots, stray input) is dropped.
    final kept = StringBuffer();
    var keptBeforeCursor = 0;
    var seenComma = false;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      final isComma = decimalDigits > 0 && ch == ',' && !seenComma;
      if (!isDigit && !isComma) continue;
      if (isComma) seenComma = true;
      kept.write(ch);
      if (i < cursor) keptBeforeCursor++;
    }
    final raw = kept.toString();
    if (raw.isEmpty) return const TextEditingValue(text: '');

    final comma = raw.indexOf(',');
    var whole = comma < 0 ? raw : raw.substring(0, comma);
    var fraction = comma < 0 ? null : raw.substring(comma + 1);
    if (fraction != null && fraction.length > decimalDigits) {
      fraction = fraction.substring(0, decimalDigits);
    }
    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.isEmpty) whole = '0';
    final formatted = '${_format.format(int.parse(whole))}${fraction == null ? '' : ',$fraction'}';

    // Walk `formatted` counting significant characters until we've passed
    // the same number that were before the cursor in the raw input — that
    // position (not the raw character offset) is where the cursor belongs,
    // so it stays anchored as separators shift around it.
    var cursorOffset = formatted.length;
    if (keptBeforeCursor == 0) {
      cursorOffset = 0;
    } else {
      var seen = 0;
      for (var i = 0; i < formatted.length; i++) {
        if (formatted[i] == '.') continue;
        seen++;
        if (seen == keptBeforeCursor) {
          cursorOffset = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset.clamp(0, formatted.length)),
    );
  }
}
