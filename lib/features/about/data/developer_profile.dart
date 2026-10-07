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
    required this.projects,
    required this.contact,
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
  final List<String> projects;
  final DeveloperContact contact;

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
    projects: [
      'Shoot Live',
      'Forests Team',
      'Mansy Store',
      'ITI Flutter Project (Clean Architecture, BLoC, Gemini AI, Wishlist)',
      'Forgery Detection (Graduation Project)',
    ],
    contact: DeveloperContact(
      email: 'ahmedelmansy1311@gmail.com',
      phone: '+20 106 799 5211',
      githubUrl: 'https://github.com/AhmedELmansy1',
      linkedinUrl: 'https://www.linkedin.com/in/ahmed-elmansy-a6b494346',
    ),
  );
}
