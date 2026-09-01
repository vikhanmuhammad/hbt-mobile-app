import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Live thousand-separator formatter for a digits-only amount `TextField`
/// (e.g. Budget Tracker's budget/amount inputs) — reformats the field's
/// text as the user types so groups of 3 digits get a separator (`.` for
/// `id_ID`, `,` for most other locales), while keeping the cursor at the
/// same logical digit position instead of jumping to the end.
///
/// Only digits are meaningful input here (no decimals); anything else typed
/// is stripped before formatting. Use [parse] to recover the raw integer
/// from a formatted string when reading a field's value back out.
class ThousandsInputFormatter extends TextInputFormatter {
  ThousandsInputFormatter({String locale = 'id_ID'}) : _format = NumberFormat.decimalPattern(locale);

  final NumberFormat _format;

  static int parse(String formatted) {
    final digitsOnly = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final digitsBeforeCursor =
        newValue.text.substring(0, newValue.selection.end).replaceAll(RegExp(r'[^0-9]'), '').length;

    final formatted = _format.format(int.parse(digitsOnly));

    // Walk `formatted` counting digits until we've passed the same number of
    // digits that were before the cursor in the raw input — that position
    // (not the raw character offset) is where the cursor belongs, so it
    // stays anchored to the same digit as separators shift around it.
    var digitsSeen = 0;
    var cursorOffset = formatted.length;
    if (digitsBeforeCursor == 0) {
      cursorOffset = 0;
    } else {
      for (var i = 0; i < formatted.length; i++) {
        if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
          digitsSeen++;
          if (digitsSeen == digitsBeforeCursor) {
            cursorOffset = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
