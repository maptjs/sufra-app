/// A scanned food product, parsed from the Open Food Facts API response.
/// Open Food Facts is a free, open, crowd-sourced food database covering
/// products sold worldwide, including many Middle Eastern / Gulf products.
class ScannedProduct {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final String ingredientsText;
  final List<String> allergenTags; // e.g. ["en:milk", "en:gluten"]
  final String? nutriScore; // a, b, c, d, e (may be null)
  final Map<String, dynamic> nutriments; // sugars_100g, salt_100g, fat_100g, etc.
  final List<String> additivesTags;

  ScannedProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.ingredientsText,
    required this.allergenTags,
    this.nutriScore,
    required this.nutriments,
    required this.additivesTags,
  });

  factory ScannedProduct.fromOpenFoodFacts(Map<String, dynamic> json, String barcode) {
    final product = json['product'] as Map<String, dynamic>? ?? {};

    String pickName() {
      // Prefer Arabic product name fields if the product has them, else fall
      // back to generic / English name.
      final candidates = [
        product['product_name_ar'],
        product['product_name'],
        product['generic_name_ar'],
        product['generic_name'],
      ];
      for (final c in candidates) {
        if (c is String && c.trim().isNotEmpty) return c.trim();
      }
      return 'منتج غير معروف';
    }

    String pickIngredients() {
      final candidates = [
        product['ingredients_text_ar'],
        product['ingredients_text'],
      ];
      for (final c in candidates) {
        if (c is String && c.trim().isNotEmpty) return c.trim();
      }
      return '';
    }

    final allergens = (product['allergens_tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final additives = (product['additives_tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final nutriments = (product['nutriments'] as Map?)?.cast<String, dynamic>() ?? {};

    return ScannedProduct(
      barcode: barcode,
      name: pickName(),
      brand: (product['brands'] as String?) ?? '',
      imageUrl: product['image_front_url'] as String?,
      ingredientsText: pickIngredients(),
      allergenTags: allergens,
      nutriScore: (product['nutriscore_grade'] as String?),
      nutriments: nutriments,
      additivesTags: additives,
    );
  }

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'imageUrl': imageUrl,
        'ingredientsText': ingredientsText,
        'allergenTags': allergenTags,
        'nutriScore': nutriScore,
        'nutriments': nutriments,
        'additivesTags': additivesTags,
      };

  factory ScannedProduct.fromJson(Map<String, dynamic> json) => ScannedProduct(
        barcode: json['barcode'],
        name: json['name'],
        brand: json['brand'] ?? '',
        imageUrl: json['imageUrl'],
        ingredientsText: json['ingredientsText'] ?? '',
        allergenTags: List<String>.from(json['allergenTags'] ?? []),
        nutriScore: json['nutriScore'],
        nutriments: Map<String, dynamic>.from(json['nutriments'] ?? {}),
        additivesTags: List<String>.from(json['additivesTags'] ?? []),
      );
}
