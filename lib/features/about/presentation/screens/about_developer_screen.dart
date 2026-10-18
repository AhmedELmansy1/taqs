import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/section_header.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';
import 'package:taqs/features/about/presentation/widgets/about_footer.dart';
import 'package:taqs/features/about/presentation/widgets/contact_section.dart';
import 'package:taqs/features/about/presentation/widgets/developer_hero_header.dart';
import 'package:taqs/features/about/presentation/widgets/education_card.dart';
import 'package:taqs/features/about/presentation/widgets/projects_list.dart';
import 'package:taqs/features/about/presentation/widgets/skills_chip_group.dart';
import 'package:taqs/features/about/presentation/widgets/tech_focus_card.dart';
import 'package:taqs/features/about/presentation/widgets/why_taqs_card.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Screen displaying verified information about the developer (Ahmed Elmansy).
class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    const profile = DeveloperProfile.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutDeveloper),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              // Hero Profile
              DeveloperHeroHeader(
                profile: profile,
                isArabic: isArabic,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tech Focus Tri-Pillar Card
              TechFocusCard(isArabic: isArabic),
              const SizedBox(height: AppSpacing.xl),

              // Education Section
              SectionHeader(title: l10n.educationSectionTitle),
              const SizedBox(height: AppSpacing.xs),
              EducationCard(
                education: profile.education,
                isArabic: isArabic,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Skills Section (Grouped by Category)
              SectionHeader(title: l10n.skillsSectionTitle),
              const SizedBox(height: AppSpacing.xs),
              SkillsChipGroup(
                skills: profile.skills,
                categories: profile.skillCategories,
                isArabic: isArabic,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Projects Section (Verified Projects)
              SectionHeader(title: l10n.projectsSectionTitle),
              const SizedBox(height: AppSpacing.xs),
              ProjectsList(
                projects: profile.projects,
                projectItems: profile.projectItems,
                isArabic: isArabic,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Why Taqs Architectural Note
              WhyTaqsCard(
                whyTaqsText: isArabic ? profile.whyTaqsAr : profile.whyTaqsEn,
                isArabic: isArabic,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Contact Section
              SectionHeader(title: l10n.contactSectionTitle),
              const SizedBox(height: AppSpacing.xs),
              ContactSection(contact: profile.contact),

              // Footer with Share, Licenses, and Open-Meteo
              AboutFooter(isArabic: isArabic),
            ],
          ),
        ),
      ),
    );
  }
}
