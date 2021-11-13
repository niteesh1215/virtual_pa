import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/model/app_theme.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({Key? key, required this.label, this.onPressed})
      : super(key: key);
  final Widget label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: Chip(
        side: BorderSide(color: context.read<AppTheme>().borderColor),
        label: label,
      ),
    );
  }
}
