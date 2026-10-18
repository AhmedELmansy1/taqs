import 'package:flutter/foundation.dart';

/// Contact information details for the developer.
@immutable
class DeveloperContact {
  const DeveloperContact({
    required this.email,
    required this.phone,
    required this.githubUrl,
    required this.linkedinUrl,
  });

  final String email;
  final String phone;
  final String githubUrl;
  final String linkedinUrl;
}

/// Education background details for the developer.
@immutable
class DeveloperEducation {
  const DeveloperEducation({
    required this.degreeAr,
    required this.degreeEn,
    required this.specializationAr,
    required this.specializationEn,
    required this.graduationProjectAr,
    required this.graduationProjectEn,
  });

  final String degreeAr;
  final String degreeEn;
  final String specializationAr;
  final String specializationEn;
  final String graduationProjectAr;
  final String graduationProjectEn;
}

/// Categorized skill grouping without misleading proficiency bars.
@immutable
class SkillCategory {
  const SkillCategory({
    required this.nameAr,
    required this.nameEn,
    required this.skills,
  });

  final String nameAr;
  final String nameEn;
  final List<String> skills;
}

/// Verified project item containing factual project name and optional metadata.
@immutable
class ProjectItem {
  const ProjectItem({
    required this.name,
    this.tagAr,
    this.tagEn,
  });

  final String name;
  final String? tagAr;
  final String? tagEn;
}

/// Typed immutable model holding the developer's exact profile data.
///
/// Easily editable in a single centralized location without modifying UI components.
@immutable
class DeveloperProfile {
  const DeveloperProfile({
    required this.nameAr,
    required this.nameEn,
    required this.titleAr,
    required this.titleEn,
    required this.locationAr,
    required this.locationEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.education,
    required this.skills,
    required this.skillCategories,
    required this.projects,
    required this.projectItems,
    required this.contact,
    required this.whyTaqsAr,
    required this.whyTaqsEn,
  });

  final String nameAr;
  final String nameEn;
  final String titleAr;
  final String titleEn;
  final String locationAr;
  final String locationEn;
  final String summaryAr;
  final String summaryEn;
  final DeveloperEducation education;
  final List<String> skills;
  final List<SkillCategory> skillCategories;
  final List<String> projects;
  final List<ProjectItem> projectItems;
  final DeveloperContact contact;
  final String whyTaqsAr;
  final String whyTaqsEn;

  /// Pre-configured const instance containing Ahmed Elmansy's exact profile.
  static const DeveloperProfile current = DeveloperProfile(
    nameAr: 'أحمد المنسي',
    nameEn: 'Ahmed Elmansy',
    titleAr: 'مطور تطبيقات فلاتر • أمن سيبراني • ذكاء اصطناعي',
    titleEn: 'Flutter Developer • Cybersecurity • AI',
    locationAr: 'الشرقية، مصر',
    locationEn: 'Sharqia, Egypt',
    summaryAr:
        'مطور تطبيقات فلاتر، وشغوف بالذكاء الاصطناعي والأمن السيبراني، خريج علوم الحاسب.',
    summaryEn:
        'Flutter Developer, AI & Cybersecurity enthusiast, Computer Science graduate.',
    education: DeveloperEducation(
      degreeAr: 'بكالوريوس الحاسبات والمعلومات، جامعة بنها',
      degreeEn:
          "Bachelor's in Computer Science and Information, Benha University",
      specializationAr:
          'التخصص: أمن المعلومات والأدلة الجنائية الرقمية (تقدير: جيد جداً)',
      specializationEn:
          'Specialization: Information Security & Digital Forensics (Grade: Very Good)',
      graduationProjectAr:
          'مشروع التخرج: كشف التزييف الرقمي (كشف تزييف الصور والصوتيات بالذكاء الاصطناعي) — امتياز',
      graduationProjectEn:
          'Graduation Project: Forgery Detection (AI-powered image/audio forgery detection) — Excellent',
    ),
    skills: [
      'Flutter',
      'Dart',
      'Python',
      'FastAPI',
      'UI/UX',
      'REST APIs',
      'Git',
      'GitHub',
      'AI/ML',
      'Cybersecurity',
      'Digital Forensics',
    ],
    skillCategories: [
      SkillCategory(
        nameAr: 'تطوير واجهات وتطبيقات الموبايل',
        nameEn: 'Mobile & Frontend',
        skills: ['Flutter', 'Dart', 'UI/UX'],
      ),
      SkillCategory(
        nameAr: 'الأنظمة الخلفية والواجهات البرمجية',
        nameEn: 'Backend & APIs',
        skills: ['Python', 'FastAPI', 'REST APIs', 'Git', 'GitHub'],
      ),
      SkillCategory(
        nameAr: 'الذكاء الاصطناعي والأمن الرقمي',
        nameEn: 'AI & Cybersecurity',
        skills: ['AI/ML', 'Cybersecurity', 'Digital Forensics'],
      ),
    ],
    projects: [
      'Shoot Live',
      'Forests Team',
      'Mansy Store',
      'ITI Flutter Project (Clean Architecture, BLoC, Gemini AI, Wishlist)',
      'Forgery Detection (Graduation Project)',
    ],
    projectItems: [
      ProjectItem(name: 'Shoot Live'),
      ProjectItem(name: 'Forests Team'),
      ProjectItem(name: 'Mansy Store'),
      ProjectItem(
        name: 'ITI Flutter Project',
        tagAr: 'Clean Architecture, BLoC, Gemini AI, Wishlist',
        tagEn: 'Clean Architecture, BLoC, Gemini AI, Wishlist',
      ),
      ProjectItem(
        name: 'Forgery Detection',
        tagAr: 'مشروع التخرج: كشف تزييف الصور والصوتيات بالذكاء الاصطناعي (امتياز)',
        tagEn: 'Graduation Project: AI-powered image/audio forgery detection (Excellent)',
      ),
    ],
    contact: DeveloperContact(
      email: 'ahmedelmansy1311@gmail.com',
      phone: '+20 106 799 5211',
      githubUrl: 'https://github.com/AhmedELmansy1',
      linkedinUrl: 'https://www.linkedin.com/in/ahmed-elmansy-a6b494346',
    ),
    whyTaqsAr:
        'تطبيق طقس ومواقيت الصلاة هو تطبيق عربي مصمم بأعلى معايير الجودة، مبني وفق هندسة برمجية نظيفة (Clean Architecture) وإدارة حالة معتمدة على Riverpod، مع معالجة البيانات وحساب المواقيت بدقة محلياً دون أي بيانات مفبركة.',
    whyTaqsEn:
        'Taqs (Weather & Prayer Times) is an Arabic-first app engineered with Clean Architecture and Riverpod, ensuring reliable, offline-first meteorological data and astronomical prayer calculations with zero synthetic metrics.',
  );
}
