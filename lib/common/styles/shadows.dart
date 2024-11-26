import 'package:cr_admin/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TShodowStyle {
  static final verticalProductShadow = BoxShadow(
    color: TColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: Offset(
      0,
      2,
    ),
  );
  static final horizontalProductShadow = BoxShadow(
    color: TColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: Offset(
      0,
      2,
    ),
  );
}
