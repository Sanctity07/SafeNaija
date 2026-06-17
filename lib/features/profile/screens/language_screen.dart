import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'English';

  final List<_Language> _languages = const [
    _Language(
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      code: 'EN',
      speakers: 'Official language',
    ),
    _Language(
      name: 'Yoruba',
      nativeName: 'Yorùbá',
      flag: '🟢',
      code: 'YO',
      speakers: 'Southwest Nigeria · ~45M speakers',
    ),
    _Language(
      name: 'Hausa',
      nativeName: 'Hausa',
      flag: '🟡',
      code: 'HA',
      speakers: 'North Nigeria · ~70M speakers',
    ),
    _Language(
      name: 'Igbo',
      nativeName: 'Igbo',
      flag: '🔵',
      code: 'IG',
      speakers: 'Southeast Nigeria · ~44M speakers',
    ),
    _Language(
      name: 'Pidgin',
      nativeName: 'Naija Pidgin',
      flag: '🇳🇬',
      code: 'PCM',
      speakers: 'Across Nigeria · ~75M speakers',
    ),
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
    _entryController.dispose();
    super.dispose();
  }

  void _selectLanguage(String language) {
    setState(() => _selectedLanguage = language);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language set to $language',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
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
                _LanguageHeader(onBack: () => Navigator.pop(context)),

                // Body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    children: [
                      // Info card
                      _InfoCard(),

                      const SizedBox(height: 20),

                      // Language list label
                      Text(
                        'SELECT LANGUAGE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Language list
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: _languages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final lang = entry.value;
                            final isSelected =
                                lang.name == _selectedLanguage;
                            final isLast = index == _languages.length - 1;

                            return Column(
                              children: [
                                _LanguageTile(
                                  language: lang,
                                  isSelected: isSelected,
                                  onTap: () => _selectLanguage(lang.name),
                                ),
                                if (!isLast)
                                  const Divider(
                                    color: AppColors.border,
                                    height: 1,
                                    indent: 56,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Coming soon card
                      _ComingSoonCard(),
                    ],
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
class _LanguageHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _LanguageHeader({required this.onBack});

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
                Text('Language', style: AppTextStyles.headingLarge),
                Text(
                  'Choose your preferred language',
                  style: AppTextStyles.caption,
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
// INFO CARD
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.safeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.translate_rounded,
            color: AppColors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Alerts and app content will be displayed in your selected language.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.green.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANGUAGE TILE
// ─────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        child: Row(
          children: [
            // Flag / emoji
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.green.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  language.code,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.green
                        : AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        language.flag,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (language.name != language.nativeName) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${language.nativeName}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.speakers,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.green : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMING SOON CARD
// ─────────────────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

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
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More languages coming soon',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fulfulde, Kanuri, Tiv and more on the way.',
                  style: AppTextStyles.caption,
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
// DATA MODEL
// ─────────────────────────────────────────────
class _Language {
  final String name;
  final String nativeName;
  final String flag;
  final String code;
  final String speakers;

  const _Language({
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.code,
    required this.speakers,
  });
}