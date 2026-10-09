import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Using this wrapper as color prorperty will be deprecated in the future
// https://github.com/dnfield/flutter_svg/issues/856

class SvgIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color color;

  const SvgIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        height: size,
      ),
    );
  }
}