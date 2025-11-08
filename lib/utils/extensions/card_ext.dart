import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';

class TaiCard extends Card {
  const TaiCard({
    required super.child,
    super.key,
    super.color,
    super.shape,
    super.margin,
    double? elevation,
    Clip? clipBehavior,
    Color? shadowColor,
  }) : super(
          elevation: elevation ?? 6.0,
          shadowColor: shadowColor ?? Colors.black38,
          clipBehavior: clipBehavior ?? Clip.hardEdge,
        );

  /// The TaiCard.margin constructor creates a card with a default margin.
  TaiCard.margin({
    super.key,
    required Widget child,
    super.color,
    super.shape,
    double? elevation,
    Clip? clipBehavior,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? shadowColor,
  }) : super(
          elevation: elevation ?? 6.0,
          shadowColor: shadowColor ?? Colors.black38,
          clipBehavior: clipBehavior ?? Clip.hardEdge,
          margin: margin ?? const EdgeInsets.all(Spacing.s),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(Spacing.m),
            child: child,
          ),
        );
}
