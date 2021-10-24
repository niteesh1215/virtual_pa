import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.onPressed,
    this.icon,
    this.iconData,
    this.color = Colors.white,
    this.radius = 24.0,
  })  : assert(icon != null || iconData != null,
            'either icon or iconData must be provided'),
        super(key: key);

  final VoidCallback onPressed;
  final Color color;
  final IconData? iconData;
  final Widget? icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon ??
          Icon(
            iconData,
            color: color,
          ),
      splashRadius: radius,
    );
  }
}
