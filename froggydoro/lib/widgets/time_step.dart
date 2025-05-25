import 'package:flutter/material.dart';

class TimeStep extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? unit;

  const TimeStep({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.unit,
  });

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFABC2A9)
        : const Color(0xFF586F51);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor(context);

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onDecrement,
                visualDensity: VisualDensity.compact,
              ),
              Text(
                unit != null ? '$value $unit' : '$value',
                style: TextStyle(fontSize: 17, color: textColor),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onIncrement,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
