import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/model/app_theme.dart';

class CustomChip extends StatelessWidget {
  const CustomChip(
      {Key? key, required this.label, this.isSelected = false, this.onPressed})
      : super(key: key);
  final Widget label;
  final VoidCallback? onPressed;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: Chip(
        side: BorderSide(color: context.read<AppTheme>().borderColor),
        label: label,
        labelStyle: isSelected
            ? Theme.of(context).chipTheme.secondaryLabelStyle
            : Theme.of(context).chipTheme.labelStyle,
        backgroundColor: isSelected
            ? Theme.of(context).chipTheme.selectedColor
            : Theme.of(context).chipTheme.backgroundColor,
      ),
    );
  }
}
