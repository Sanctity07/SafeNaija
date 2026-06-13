// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedCategory = -1;
  int _selectedSeverity = -1;
  bool _isAnonymous = true;
  bool _isLoading = false;
  String _selectedState = '';
  String _selectedLga = '';

  final List<_IncidentCategory> _categories = const [
    _IncidentCategory(
      icon: Icons.warning_amber_rounded,
      label: 'Banditry',
      color: Color(0xFFFF3B30),
    ),
    _IncidentCategory(
      icon: Icons.money_off_rounded,
      label: 'Robbery',
      color: Color(0xFFFF3B30),
    ),
    _IncidentCategory(
      icon: Icons.person_off_rounded,
      label: 'Kidnapping',
      color: Color(0xFFFF3B30),
    ),
    _IncidentCategory(
      icon: Icons.groups_rounded,
      label: 'Cult Clash',
      color: Color(0xFFFF9500),
    ),
    _IncidentCategory(
      icon: Icons.remove_road_rounded,
      label: 'Bad Road',
      color: Color(0xFFFF9500),
    ),
    _IncidentCategory(
      icon: Icons.visibility_rounded,
      label: 'Suspicious',
      color: Color(0xFF00C853),
    ),
    _IncidentCategory(
      icon: Icons.local_fire_department_rounded,
      label: 'Fire',
      color: Color(0xFFFF9500),
    ),
    _IncidentCategory(
      icon: Icons.flood_rounded,
      label: 'Flooding',
      color: Color(0xFF00C853),
    ),
    _IncidentCategory(
      icon: Icons.more_horiz_rounded,
      label: 'Other',
      color: Color(0xFF888888),
    ),
  ];

  final List<_SeverityOption> _severities = const [
    _SeverityOption(
      label: 'Low',
      description: 'Minor issue',
      color: AppColors.green,
      bg: AppColors.safeBg,
      icon: Icons.arrow_downward_rounded,
    ),
    _SeverityOption(
      label: 'Medium',
      description: 'Needs attention',
      color: AppColors.warning,
      bg: AppColors.warningBg,
      icon: Icons.remove_rounded,
    ),
    _SeverityOption(
      label: 'High',
      description: 'Immediate danger',
      color: AppColors.danger,
      bg: AppColors.dangerBg,
      icon: Icons.arrow_upward_rounded,
    ),
  ];

  final List<String> _nigerianStates = const [
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
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
    _descriptionController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedCategory != -1 &&
      _selectedSeverity != -1 &&
      _selectedState.isNotEmpty &&
      _descriptionController.text.trim().length >= 10;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == -1) {
      _showError('Please select an incident type');
      return;
    }
    if (_selectedSeverity == -1) {
      _showError('Please select a severity level');
      return;
    }
    if (_selectedState.isEmpty) {
      _showError('Please select a state');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.reportSuccess);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                _ReportHeader(onBack: () => Navigator.pop(context)),

                // Scrollable form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      children: [
                        // Step 1 — Category
                        _StepLabel(number: '01', label: 'Incident Type'),
                        const SizedBox(height: 12),
                        _CategoryGrid(
                          categories: _categories,
                          selected: _selectedCategory,
                          onSelect: (i) =>
                              setState(() => _selectedCategory = i),
                        ),

                        const SizedBox(height: 24),

                        // Step 2 — Severity
                        _StepLabel(number: '02', label: 'Severity Level'),
                        const SizedBox(height: 12),
                        _SeveritySelector(
                          severities: _severities,
                          selected: _selectedSeverity,
                          onSelect: (i) =>
                              setState(() => _selectedSeverity = i),
                        ),

                        const SizedBox(height: 24),

                        // Step 3 — Location
                        _StepLabel(number: '03', label: 'Location'),
                        const SizedBox(height: 12),
                        _LocationSelector(
                          states: _nigerianStates,
                          selectedState: _selectedState,
                          selectedLga: _selectedLga,
                          onStateChanged: (val) => setState(() {
                            _selectedState = val ?? '';
                            _selectedLga = '';
                          }),
                          onLgaChanged: (val) =>
                              setState(() => _selectedLga = val ?? ''),
                        ),

                        const SizedBox(height: 24),

                        // Step 4 — Description
                        _StepLabel(number: '04', label: 'What Happened?'),
                        const SizedBox(height: 12),
                        _DescriptionField(
                          controller: _descriptionController,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 24),

                        // Step 5 — Photo (optional)
                        _StepLabel(
                          number: '05',
                          label: 'Add Photo',
                          optional: true,
                        ),
                        const SizedBox(height: 12),
                        const _PhotoUploader(),

                        const SizedBox(height: 24),

                        // Anonymous toggle
                        _AnonymousToggle(
                          isAnonymous: _isAnonymous,
                          onToggle: (val) =>
                              setState(() => _isAnonymous = val),
                        ),

                        const SizedBox(height: 28),

                        // Submit
                        _SubmitButton(
                          canSubmit: _canSubmit,
                          isLoading: _isLoading,
                          onTap: _submit,
                        ),

                        const SizedBox(height: 12),

                        // Disclaimer
                        Center(
                          child: Text(
                            'False reports may result in account suspension.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
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
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _ReportHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ReportHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
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
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Incident', style: AppTextStyles.headingLarge),
                Text(
                  'Help keep your community safe',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // SOS badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.danger.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP LABEL
// ─────────────────────────────────────────────
class _StepLabel extends StatelessWidget {
  final String number;
  final String label;
  final bool optional;

  const _StepLabel({
    required this.number,
    required this.label,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(optional)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY GRID
// ─────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final List<_IncidentCategory> categories;
  final int selected;
  final ValueChanged<int> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = index == selected;

        return GestureDetector(
          onTap: () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withOpacity(0.1)
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? cat.color.withOpacity(0.5)
                    : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  color: isSelected ? cat.color : AppColors.textMuted,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? cat.color : AppColors.textMuted,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SEVERITY SELECTOR
// ─────────────────────────────────────────────
class _SeveritySelector extends StatelessWidget {
  final List<_SeverityOption> severities;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SeveritySelector({
    required this.severities,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: severities.asMap().entries.map((entry) {
        final index = entry.key;
        final sev = entry.value;
        final isSelected = index == selected;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? sev.bg : AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? sev.color.withOpacity(0.5)
                      : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    sev.icon,
                    color: isSelected ? sev.color : AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sev.label,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? sev.color : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sev.description,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? sev.color.withOpacity(0.7)
                          : AppColors.textMuted.withOpacity(0.6),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION SELECTOR
// ─────────────────────────────────────────────
class _LocationSelector extends StatelessWidget {
  final List<String> states;
  final String selectedState;
  final String selectedLga;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onLgaChanged;

  const _LocationSelector({
    required this.states,
    required this.selectedState,
    required this.selectedLga,
    required this.onStateChanged,
    required this.onLgaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Auto-detect button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.safeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use my current location',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to auto-detect',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.green.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Or divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('or enter manually', style: AppTextStyles.caption),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),

        const SizedBox(height: 8),

        // State dropdown
        _StyledDropdown(
          hint: 'Select State',
          prefixIcon: Icons.map_outlined,
          value: selectedState.isEmpty ? null : selectedState,
          items: states,
          onChanged: onStateChanged,
        ),

        const SizedBox(height: 8),

        // LGA field
        TextFormField(
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter LGA / Area (optional)',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(
              Icons.location_city_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          onChanged: (val) => onLgaChanged(val),
        ),
      ],
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.prefixIcon,
    required this.value,
    required this.items,
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
          value: value,
          hint: Row(
            children: [
              Icon(prefixIcon, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Text(
                hint,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
          dropdownColor: AppColors.surface2,
          isExpanded: true,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DESCRIPTION FIELD
// ─────────────────────────────────────────────
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 4,
          maxLength: 300,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please describe what happened';
            }
            if (val.trim().length < 10) {
              return 'Please provide more detail';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText:
                'Describe what you saw — be specific about time, people, vehicles...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            alignLabelWithHint: true,
            counterStyle: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PHOTO UPLOADER
// ─────────────────────────────────────────────
class _PhotoUploader extends StatelessWidget {
  const _PhotoUploader();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to add photo evidence',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Max 5MB · JPG or PNG',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted.withOpacity(0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANONYMOUS TOGGLE
// ─────────────────────────────────────────────
class _AnonymousToggle extends StatelessWidget {
  final bool isAnonymous;
  final ValueChanged<bool> onToggle;

  const _AnonymousToggle({
    required this.isAnonymous,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isAnonymous ? AppColors.safeBg : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isAnonymous
                    ? AppColors.green.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Icon(
              isAnonymous
                  ? Icons.visibility_off_outlined
                  : Icons.person_outline_rounded,
              color: isAnonymous ? AppColors.green : AppColors.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Anonymously',
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  isAnonymous
                      ? 'Your identity will be hidden'
                      : 'Your verified badge will show',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!isAnonymous),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: isAnonymous ? AppColors.green : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isAnonymous ? AppColors.green : AppColors.border,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isAnonymous
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
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
// SUBMIT BUTTON
// ─────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.canSubmit,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canSubmit && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: canSubmit
              ? isLoading
                  ? AppColors.green.withOpacity(0.6)
                  : AppColors.green
              : AppColors.surface2,
          borderRadius: BorderRadius.circular(100),
          boxShadow: canSubmit && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
          border: Border.all(
            color: canSubmit ? Colors.transparent : AppColors.border,
          ),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: canSubmit
                          ? Colors.black
                          : AppColors.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Report',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: canSubmit
                            ? Colors.black
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class _IncidentCategory {
  final IconData icon;
  final String label;
  final Color color;

  const _IncidentCategory({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _SeverityOption {
  final String label;
  final String description;
  final Color color;
  final Color bg;
  final IconData icon;

  const _SeverityOption({
    required this.label,
    required this.description,
    required this.color,
    required this.bg,
    required this.icon,
  });
}