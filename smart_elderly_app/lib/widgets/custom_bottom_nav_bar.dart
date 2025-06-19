import 'package:flutter/material.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<BottomNavigationBarItem> items;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color selectedLabelColor;
  final Color unselectedLabelColor;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.backgroundColor = AppColors.softWhite,
    this.selectedItemColor = AppColors.primary,
    this.unselectedItemColor = AppColors.lightGray,
    this.selectedLabelColor = AppColors.primary,
    this.unselectedLabelColor = AppColors.lightGray,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          int index = entry.key;
          BottomNavigationBarItem item = entry.value;
          bool isSelected = index == widget.selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onItemSelected(index),
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (item.icon as Icon).icon!,
                      color: isSelected ? widget.selectedItemColor : widget.unselectedItemColor,
                      size: isSelected ? 28 : 24,
                    ),
                    if (item.label != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label!,
                        style: TextStyle(
                          color: isSelected ? widget.selectedLabelColor : widget.unselectedLabelColor,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                    // Underline indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: isSelected ? 30 : 0,
                      decoration: BoxDecoration(
                        color: widget.selectedItemColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 