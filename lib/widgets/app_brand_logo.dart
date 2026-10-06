import 'package:flutter/material.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.size = 32, this.width, this.height});

  final double size;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Keep all app marks consistent while making them a little easier to see.
    final logoWidth = (width ?? size) * 1.12;
    final logoHeight = (height ?? size) * 1.12;

    return Image.asset(
      'assets/deslugify_logo.png',
      width: logoWidth,
      height: logoHeight,
      fit: BoxFit.contain,
      semanticLabel: 'Deslugify logo',
    );
  }
}
