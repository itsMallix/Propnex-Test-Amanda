import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get clean => trim().replaceAll(RegExp(r'\s+'), ' ');
}

extension DoubleExtension on double {
  String toCurrency() {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(this);
  }

  String toPercent() => '${toStringAsFixed(1)}%';
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  void pop<T>([T? result]) => Navigator.pop(this, result);
}
