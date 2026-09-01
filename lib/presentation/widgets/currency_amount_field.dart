import 'package:flutter/material.dart';

import 'thousands_input_formatter.dart';

/// Amount input for Budget Tracker spending fields — one cohesive bordered
/// box with the currency (e.g. "Rp") rendered as its own bold `Text` widget
/// via `prefixIcon` (not `InputDecoration.prefixText`, whose color/style
/// this app's theme was making effectively invisible), so it's guaranteed
/// visible regardless of the surrounding theme. Live thousand-separator
/// formatting, no +/- stepper (per Budget Tracker spec).
class CurrencyAmountField extends StatelessWidget {
  const CurrencyAmountField({
    super.key,
    required this.controller,
    required this.currencyPrefix,
    required this.onChanged,
    this.width,
  });

  final TextEditingController controller;

  /// e.g. "Rp " for IDR, "USD " for others — shown trimmed as a bold prefix.
  final String currencyPrefix;
  final ValueChanged<int> onChanged;

  /// Constrains the field's width when placed inline (e.g. centered in the
  /// quick-progress sheet); null lets it fill its parent (e.g. a form
  /// field's `Expanded` column).
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    );
    final field = TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
      inputFormatters: [ThousandsInputFormatter()],
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: borderColor.withValues(alpha: 0.06),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4, right: 6),
          child: Center(
            widthFactor: 1,
            child: Text(
              currencyPrefix.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: borderColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
      onChanged: (text) => onChanged(ThousandsInputFormatter.parse(text)),
    );
    if (width == null) return field;
    // Scale the fixed inline width with the system text-scale setting (the
    // app clamps that to 0.85x-1.3x, see main.dart) so a larger accessibility
    // font size gets proportionally more room instead of the field staying
    // visually fixed-size while its own text grows past it — which is what
    // was reading as "cramped" on a scaled-up display.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return SizedBox(width: width! * textScale, child: field);
  }
}
