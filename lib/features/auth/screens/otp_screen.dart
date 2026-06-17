import 'package:flutter/material.dart';
import 'dart:async';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendSeconds = 60;
  Timer? _timer;

  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _entryController.forward();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      _showSnack('Please enter the full 6-digit code', isError: true);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // TODO: Hook up FirebaseAuth — PhoneAuthCredential + signInWithCredential
      // final credential = PhoneAuthProvider.credential(
      //   verificationId: widget.verificationId,
      //   smsCode: _otpCode,
      // );
      // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      //
      // Then check Firestore for existing profile:
      // final doc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userCredential.user!.uid)
      //     .get();
      //
      // if (!doc.exists) {
      //   Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
      // } else {
      //   Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
      // }

      await Future.delayed(const Duration(seconds: 2)); // temp

      if (!mounted) return;

      // Temporary: assume new user, route to Complete Profile
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Invalid code. Please try again.', isError: true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0) return;

    setState(() => _isResending = true);

    // TODO: Hook up FirebaseAuth.verifyPhoneNumber again here

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isResending = false);
    _startResendTimer();
    _showSnack('Code resent successfully');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.6),
                radius: 0.7,
                colors: [
                  Color(0x0D00C853),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        children: [
                          _BackButton(onTap: () => Navigator.pop(context)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.greenGlow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.green.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.sms_rounded,
                                color: AppColors.green,
                                size: 26,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Verify your\nnumber.',
                              style: AppTextStyles.displayMedium,
                            ),

                            const SizedBox(height: 8),

                            RichText(
                              text: TextSpan(
                                text: 'We sent a 6-digit code to ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.phoneNumber,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 36),

                            // OTP boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return _OtpBox(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (val) =>
                                      _onDigitChanged(index, val),
                                );
                              }),
                            ),

                            const SizedBox(height: 32),

                            _SubmitButton(
                              isLoading: _isVerifying,
                              label: 'Verify Code',
                              onTap: _verifyOtp,
                            ),

                            const SizedBox(height: 24),

                            // Resend
                            Center(
                              child: _resendSeconds > 0
                                  ? Text(
                                      'Resend code in $_resendSeconds s',
                                      style: AppTextStyles.bodySmall,
                                    )
                                  : GestureDetector(
                                      onTap: _isResending ? null : _resendCode,
                                      child: Text(
                                        _isResending
                                            ? 'Resending...'
                                            : 'Resend Code',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OTP DIGIT BOX
// ─────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = controller.text.isNotEmpty;

    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyles.headingLarge.copyWith(fontSize: 22),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface2,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isFilled ? AppColors.green : AppColors.border,
              width: isFilled ? 1.5 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isFilled ? AppColors.green : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 16,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isLoading
              ? AppColors.green.withOpacity(0.6)
              : AppColors.green,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.black),
                ),
        ),
      ),
    );
  }
}