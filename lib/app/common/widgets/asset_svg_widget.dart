import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetSvgWidget extends StatelessWidget {
  final double? radius;
  final double? height;
  final double? width;
  final String? svgPath;
  final BoxFit? fit;
  final Color? color;
  final ColorFilter? colorFilter;

  const AssetSvgWidget({
    super.key,
    this.radius,
    required this.svgPath,
    this.fit,
    this.height,
    this.width,
    this.color,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    Widget svgWidget = SvgPicture.asset(
      svgPath ?? "",
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      colorFilter:
          colorFilter ??
          (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
    );

    if (radius != null && radius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: svgWidget,
      );
    }

    return svgWidget;
  }
}
