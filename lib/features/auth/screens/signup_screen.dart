import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedState;

  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi',
    'Bayelsa', 'Benue', 'Borno', 'Cross River', 'Delta',
    'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'FCT - Abuja',
    'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano',
    'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos',
    'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun',
    'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba',
    'Yobe', 'Zamfara',
  ];

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedState == null) {
      _showStateError();
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // temp
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  void _showStateError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please select your state',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
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
          // Background glow
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        children: [
                          _BackButton(
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title block
                              Text(
                                'Create\nyour account.',
                                style: AppTextStyles.displayMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join thousands of Nigerians keeping\neach other safe.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Full name
                              _FieldLabel(label: 'Full Name'),
                              const SizedBox(height: 8),
                              _AppTextField(
                                controller: _nameController,
                                hint: 'e.g. Lucky Amiara',
                                prefixIcon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.name,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  if (val.trim().length < 2) {
                                    return 'Name is too short';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Phone number
                              _FieldLabel(label: 'Phone Number'),
                              const SizedBox(height: 8),
                              _AppTextField(
                                controller: _phoneController,
                                hint: '080XXXXXXXX',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (val.trim().length < 10) {
                                    return 'Enter a valid Nigerian number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // State
                              _FieldLabel(label: 'State of Residence'),
                              const SizedBox(height: 8),
                              _StateDropdown(
                                states: _nigerianStates,
                                selectedState: _selectedState,
                                onChanged: (val) =>
                                    setState(() => _selectedState = val),
                              ),

                              const SizedBox(height: 20),

                              // Password
                              _FieldLabel(label: 'Password'),
                              const SizedBox(height: 8),
                              _AppTextField(
                                controller: _passwordController,
                                hint: 'Min. 8 characters',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (val.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Terms notice
                              _TermsNotice(),

                              const SizedBox(height: 32),

                              // Submit button
                              _SubmitButton(
                                isLoading: _isLoading,
                                onTap: _submit,
                              ),

                              const SizedBox(height: 20),

                              // Sign in link
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.signIn,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: AppTextStyles.bodySmall,
                                      children: [
                                        TextSpan(
                                          text: 'Sign In',
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BACK BUTTON
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

// ─────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TEXT FIELD
// ─────────────────────────────────────────────
class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATE DROPDOWN
// ─────────────────────────────────────────────
class _StateDropdown extends StatelessWidget {
  final List<String> states;
  final String? selectedState;
  final ValueChanged<String?> onChanged;

  const _StateDropdown({
    required this.states,
    required this.selectedState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedState,
          hint: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Text(
                'Select your state',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted),
          dropdownColor: AppColors.surface2,
          isExpanded: true,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          items: states.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TERMS NOTICE
// ─────────────────────────────────────────────
class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'By creating an account, you agree to our ',
        style: AppTextStyles.caption.copyWith(height: 1.6),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUBMIT BUTTON
// ─────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({required this.isLoading, required this.onTap});

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
                  'Create Account',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}