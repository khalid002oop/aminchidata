import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.width,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor ?? Colors.white)),
                ],
              ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  const OutlineButton({super.key, required this.label, this.onPressed, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor ?? AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: borderColor ?? AppColors.primary)),
      ),
    );
  }
}
