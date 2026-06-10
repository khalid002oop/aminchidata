import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/constants/app_colors.dart';

class PinInput extends StatelessWidget {
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final int length;

  const PinInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.controller,
    this.length = 4,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      controller: controller,
      obscureText: true,
      obscuringCharacter: '●',
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 60,
        fieldWidth: 56,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.border,
        selectedColor: AppColors.primary,
      ),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
      onCompleted: onCompleted,
      onChanged: onChanged ?? (_) {},
    );
  }
}
