import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

Widget BuildShimmer({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    ),
  );
}
