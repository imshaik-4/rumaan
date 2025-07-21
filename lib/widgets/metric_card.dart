import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Card theme is already set in appTheme, so no need to repeat elevation/shape
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48.sp, color: colorScheme.primary),
              SizedBox(height: 16.h),
            ],
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}