import '../models/family_member.dart';
import '../models/scanned_product.dart';

enum SafetyLevel { safe, caution, danger }

class FlagReason {
  final String memberName; // empty string = general flag, not member-specific
  final String message;
  FlagReason(this.memberName, this.message);
}

class SafetyResult {
  final SafetyLevel level;
  final int score; // 0-100, just for display ("Sufra Score")
  final List<FlagReason> reasons;
  SafetyResult(this.level, this.score, this.reasons);
}

/// A small list of additives that are commonly flagged by health-conscious
/// parents (artificial colors, certain preservatives, high-fructose
/// ingredients). This is NOT medical advice — just a transparent, editable
/// "things to be aware of" list, shown with the reasoning, not just a score.
class RedFlagAdditives {
  static const Map<String, String> tagToArabicReason = {
    'en:e102': 'يحتوي على صبغة تارترازين الصناعية (E102)',
    'en:e110': 'يحتوي على صبغة صناعية (E110)',
    'en:e122': 'يحتوي على صبغة كارموزين الصناعية (E122)',
    'en:e211': 'يحتوي على بنزوات الصوديوم كمادة حافظة (E211)',
    'en:e621': 'يحتوي على غلوتامات أحادية الصوديوم (MSG / E621)',
    'en:e951': 'يحتوي على أسبارتام، محلي صناعي (E951)',
  };
}

class SafetyScoreService {
  SafetyResult evaluate({
    required ScannedProduct product,
    required List<FamilyMember> family,
  }) {
    final reasons = <FlagReason>[];
    int score = 100;

    // 1) Check each family member's declared allergens against the product's
    //    allergen tags (Open Food Facts standard vocabulary).
    for (final member in family) {
      for (final tag in member.allergyTags) {
        if (product.allergenTags.contains(tag)) {
          final label = _arabicLabelForTag(tag);
          reasons.add(FlagReason(member.name, 'يحتوي على $label — قد يكون غير مناسب لـ ${member.name}'));
          score -= 40;
        }
      }
      // 2) Free-text "watch ingredient" keywords against the ingredients list.
      for (final keyword in member.watchIngredients) {
        if (keyword.trim().isEmpty) continue;
        if (product.ingredientsText.contains(keyword.trim())) {
          reasons.add(FlagReason(member.name, 'يحتوي على "${keyword.trim()}" — من العناصر التي تتم متابعتها لـ ${member.name}'));
          score -= 15;
        }
      }
    }

    // 3) General red-flag additives, not tied to a specific family member.
    for (final additive in product.additivesTags) {
      final reason = RedFlagAdditives.tagToArabicReason[additive];
      if (reason != null) {
        reasons.add(FlagReason('', reason));
        score -= 10;
      }
    }

    // 4) Light nutri-score influence, since it's a recognized public signal.
    switch (product.nutriScore?.toLowerCase()) {
      case 'd':
        score -= 8;
        break;
      case 'e':
        score -= 15;
        break;
    }

    score = score.clamp(0, 100);

    SafetyLevel level;
    final hasAllergenHit = reasons.any((r) => r.memberName.isNotEmpty);
    if (hasAllergenHit || score < 45) {
      level = SafetyLevel.danger;
    } else if (score < 75) {
      level = SafetyLevel.caution;
    } else {
      level = SafetyLevel.safe;
    }

    return SafetyResult(level, score, reasons);
  }

  String _arabicLabelForTag(String tag) {
    final entry = CommonAllergens.arabicToTag.entries.firstWhere(
      (e) => e.value == tag,
      orElse: () => const MapEntry('مادة مسببة للحساسية', ''),
    );
    return entry.key;
  }
}
