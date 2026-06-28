/// A member of the family with their own allergy / sensitivity profile.
/// Totally local-only — never leaves the device.
class FamilyMember {
  final String id;
  String name;
  String? relation; // e.g. "ابني", "ابنتي", "أنا" (free text)
  List<String> allergyTags; // matched against product allergens_tags
  List<String> watchIngredients; // free-text ingredient keywords to flag (e.g. "سكر", "ألوان صناعية")

  FamilyMember({
    required this.id,
    required this.name,
    this.relation,
    List<String>? allergyTags,
    List<String>? watchIngredients,
  })  : allergyTags = allergyTags ?? [],
        watchIngredients = watchIngredients ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
        'allergyTags': allergyTags,
        'watchIngredients': watchIngredients,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'] as String,
        name: json['name'] as String,
        relation: json['relation'] as String?,
        allergyTags: List<String>.from(json['allergyTags'] ?? []),
        watchIngredients: List<String>.from(json['watchIngredients'] ?? []),
      );
}

/// Common allergens shown as quick-select chips in Arabic, mapped to the
/// Open Food Facts allergen tag vocabulary (English-keyed, e.g. "en:milk").
class CommonAllergens {
  static const Map<String, String> arabicToTag = {
    'الحليب ومنتجاته': 'en:milk',
    'البيض': 'en:eggs',
    'الفول السوداني': 'en:peanuts',
    'المكسرات': 'en:nuts',
    'القمح والغلوتين': 'en:gluten',
    'الصويا': 'en:soybeans',
    'السمك': 'en:fish',
    'المحار والقشريات': 'en:crustaceans',
    'السمسم': 'en:sesame-seeds',
    'الخردل': 'en:mustard',
  };
}
