import 'package:flutter/material.dart';

class CachedImageShimmerLoadingWidget extends StatelessWidget {
  const CachedImageShimmerLoadingWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!.withOpacity(0.3),
            Colors.grey[100]!.withOpacity(0.3),
            Colors.grey[300]!.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}