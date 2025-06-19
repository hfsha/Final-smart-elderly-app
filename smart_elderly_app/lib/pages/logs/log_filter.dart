import 'package:flutter/material.dart';

class LogFilter extends StatelessWidget {
  final String selectedFilter;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const LogFilter({
    super.key,
    required this.selectedFilter,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: onChanged,
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              Icon(
                _getFilterIcon(option),
                color: _getFilterColor(option),
              ),
              const SizedBox(width: 8),
              Text(_getFilterLabel(option)),
              if (selectedFilter == option)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 16),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'motion':
        return 'Motion';
      case 'fall':
        return 'Falls';
      case 'fire':
        return 'Fires';
      case 'environment':
        return 'Environment';
      default:
        return 'All Events';
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'motion':
        return Icons.directions_walk;
      case 'fall':
        return Icons.warning;
      case 'fire':
        return Icons.fireplace;
      case 'environment':
        return Icons.thermostat;
      default:
        return Icons.all_inclusive;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'motion':
        return Colors.green;
      case 'fall':
        return Colors.orange;
      case 'fire':
        return Colors.red;
      case 'environment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
