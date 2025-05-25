import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const SettingsTile({
    required this.title,
    required this.subtitle,
    this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.dark
            ? const Color(0xFFB0C8AE)
            : const Color(0xFF586F51);
    final backgroundBlockColor =
        brightness == Brightness.dark
            ? const Color(0xFF3A4A38)
            : const Color(0xFFE4E8CD);
    return Container(
      decoration: BoxDecoration(
        color: backgroundBlockColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: Text(subtitle, style: TextStyle(color: textColor)),
        trailing: trailingIcon != null ? Icon(trailingIcon) : null,
        onTap: onTap,
      ),
    );
  }
}
