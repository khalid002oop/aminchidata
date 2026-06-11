import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/biometric_service.dart';
import '../../core/utils/storage.dart';
import 'pin_input.dart';

/// Renders a PIN input with an optional fingerprint shortcut.
/// [onPinReady] fires whenever the PIN value changes (manual or biometric).
class TransactionPinField extends StatefulWidget {
  final ValueChanged<String> onPinReady;
  const TransactionPinField({super.key, required this.onPinReady});

  @override
  State<TransactionPinField> createState() => _TransactionPinFieldState();
}

class _TransactionPinFieldState extends State<TransactionPinField> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final ready = await BiometricService.isReadyForLogin();
    if (mounted) setState(() => _biometricAvailable = ready);
  }

  Future<void> _authenticateWithBiometric() async {
    final ok = await BiometricService.authenticate(
        reason: 'Use fingerprint to authorize this transaction');
    if (!ok || !mounted) return;
    final pin = await Storage.getSecurePin();
    if (pin != null && pin.isNotEmpty) {
      widget.onPinReady(pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fingerprint verified ✓'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction PIN', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        PinInput(
          onChanged:   widget.onPinReady,
          onCompleted: widget.onPinReady,
        ),
        if (_biometricAvailable) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _authenticateWithBiometric,
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fingerprint, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 10),
              const Text('Use fingerprint instead',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
        ],
      ],
    );
  }
}
