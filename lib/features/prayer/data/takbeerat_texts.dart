// ============================================================================
// REVIEW BY OWNER BEFORE RELEASE
// ============================================================================
// All religious texts, supplications, and takbeerat strings for Taqs are
// centralized in this single file. No religious text may be altered or added
// without scholarly verification and explicit review by the project owner.
//
// Sources referenced:
// - Sahih Muslim / Sahih Al-Bukhari (authentic takbeer formula and Sunnah)
// - Egyptian Dar Al-Ifta (دار الإفتاء المصرية) canonical formula for Eid Takbeerat
// ============================================================================

/// Authentic and canonical Islamic Takbeerat and pre-adhan reminder texts.
class TakbeeratTexts {
  const TakbeeratTexts._();

  // ---------------------------------------------------------------------------
  // 1. Pre-Adhan Reminder Takbeerat (5-15 minutes before the Adhan)
  // ---------------------------------------------------------------------------

  /// Standard concise Takbeer for the pre-adhan card (Arabic).
  ///
  /// "اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، لَا إِلٰهَ إِلَّا اللهُ، وَاللهُ أَكْبَرُ، اللهُ أَكْبَرُ، وَلِلّٰهِ الْحَمْدُ"
  static const String preAdhanTakbeerAr =
      'اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، لَا إِلٰهَ إِلَّا اللهُ، وَاللهُ أَكْبَرُ، اللهُ أَكْبَرُ، وَلِلّٰهِ الْحَمْدُ';

  /// English translation for the pre-adhan Takbeer.
  static const String preAdhanTakbeerEn =
      'Allah is the Greatest, Allah is the Greatest, there is no deity except Allah; Allah is the Greatest, Allah is the Greatest, and to Allah belongs all praise.';

  /// Short preparation reminder line (Arabic).
  static const String preAdhanPreparationAr = 'اقترب موعد الأذان • استعد للصلاة والذكر';

  /// Short preparation reminder line (English).
  static const String preAdhanPreparationEn = 'Adhan is approaching • Prepare for prayer and remembrance';

  // ---------------------------------------------------------------------------
  // 2. Eid Takbeerat (Eid al-Fitr & Eid al-Adha)
  // ---------------------------------------------------------------------------

  /// Concise Eid Takbeer formula (Sunnah standard).
  static const String eidTakbeerConciseAr =
      'اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، لَا إِلٰهَ إِلَّا اللهُ، اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، وَلِلّٰهِ الْحَمْدُ';

  /// English translation for the concise Eid Takbeer.
  static const String eidTakbeerConciseEn =
      'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest. There is no deity except Allah. Allah is the Greatest, Allah is the Greatest, and to Allah belongs all praise.';

  /// Full Egyptian & Arab World canonical Eid Takbeerat formula
  /// (as practiced in Egypt per Dar Al-Ifta).
  static const String eidTakbeerFullAr =
      'اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، لَا إِلٰهَ إِلَّا اللهُ، '
      'اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، وَلِلّٰهِ الْحَمْدُ. '
      'اللهُ أَكْبَرُ كَبِيرًا، وَالْحَمْدُ لِلّٰهِ كَثِيرًا، وَسُبْحَانَ اللهِ بُكْرَةً وَأَصِيلًا، '
      'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ، صَدَقَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَأَعَزَّ جُنْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ، '
      'لَا إِلٰهَ إِلَّا اللهُ، وَلَا نَعْبُدُ إِلَّا إِيَّاهُ، مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ، '
      'اللّٰهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ، وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ، وَعَلَى أَصْحَابِ سَيِّدِنَا مُحَمَّدٍ، '
      'وَعَلَى أَنْصَارِ سَيِّدِنَا مُحَمَّدٍ، وَعَلَى أَزْوَاجِ سَيِّدِنَا مُحَمَّدٍ، وَعَلَى ذُرِّيَّةِ سَيِّدِنَا مُحَمَّدٍ، '
      'وَسَلِّمْ تَسْلِيمًا كَثِيرًا.';

  /// English translation for the full Eid Takbeerat.
  static const String eidTakbeerFullEn =
      'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest. There is no deity except Allah. '
      'Allah is the Greatest, Allah is the Greatest, and to Allah belongs all praise. '
      'Allah is the Greatest in all greatness, abundant praise belongs to Allah, and glory be to Allah morning and evening. '
      'There is no deity except Allah alone; He fulfilled His promise, granted victory to His servant, strengthened His forces, and defeated the factions alone. '
      'There is no deity except Allah, and we worship none but Him, sincerely dedicating our faith to Him even if the disbelievers despise it. '
      'O Allah, send blessings upon our Master Muhammad, and upon the family of our Master Muhammad, and upon the companions of our Master Muhammad, '
      'and upon the supporters of our Master Muhammad, and upon the wives of our Master Muhammad, and upon the progeny of our Master Muhammad, and grant abundant peace.';

  /// Eid greeting header (Arabic).
  static const String eidGreetingAr = 'تقبل الله منا ومنكم صالح الأعمال • عيد مبارك';

  /// Eid greeting header (English).
  static const String eidGreetingEn = 'May Allah accept from us and you • Eid Mubarak';
}
