import 'package:flutter/material.dart' show Color;
import 'remove_all.dart';

extension HexToColor on String {
  Color hexToColor() => Color(
        int.parse(
          removeAll(['#', '0x']).padLeft(8, 'FF'),
          radix: 16,
        ),
      );
}
