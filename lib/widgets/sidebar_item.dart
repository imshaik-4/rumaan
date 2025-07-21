import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool isDrawerItem;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
    this.isDrawerItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: isDrawerItem ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDrawerItem ? colorScheme.primary.withOpacity(0.1) : colorScheme.secondary)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 24.sp,
          color: isSelected
              ? (isDrawerItem ? colorScheme.primary : colorScheme.onSecondary)
              : (isDrawerItem ? Colors.grey[700] : colorScheme.onPrimary.withOpacity(0.7)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDrawerItem ? colorScheme.primary : colorScheme.onSecondary)
                      : (isDrawerItem ? Colors.black87 : colorScheme.onPrimary.withOpacity(0.7)),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (badgeCount != null) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDrawerItem ? Colors.grey[300] : colorScheme.onPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDrawerItem ? Colors.black87 : colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}