import 'package:flutter/material.dart';

class TimeRangeSelector extends StatelessWidget {
  final int selectedHours;
  final ValueChanged<int> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selectedHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.timeline),
      onSelected: onChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 6,
          child: Text('Last 6 hours'),
        ),
        const PopupMenuItem(
          value: 12,
          child: Text('Last 12 hours'),
        ),
        const PopupMenuItem(
          value: 24,
          child: Text('Last 24 hours'),
        ),
        const PopupMenuItem(
          value: 168,
          child: Text('Last week'),
        ),
      ],
      tooltip: 'Select time range',
    );
  }
}
