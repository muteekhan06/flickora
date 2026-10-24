import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FlickoraTheme.bgCard,
      highlightColor: FlickoraTheme.bgCardHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: FlickoraTheme.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerHorizontalList extends StatelessWidget {
  final double height;
  final double itemWidth;

  const ShimmerHorizontalList({
    super.key,
    this.height = 200,
    this.itemWidth = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => ShimmerLoader(
          width: itemWidth,
          height: height,
        ),
      ),
    );
  }
}
