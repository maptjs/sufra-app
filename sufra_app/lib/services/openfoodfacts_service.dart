import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scanned_product.dart';

class ProductLookupException implements Exception {
  final String message;
  ProductLookupException(this.message);
  @override
  String toString() => message;
}

/// Looks up products by barcode using the free, open Open Food Facts API.
/// Docs: https://openfoodfacts.github.io/openfoodfacts-server/api/
class OpenFoodFactsService {
  static const _base = 'https://world.openfoodfacts.org/api/v2/product';

  Future<ScannedProduct> lookup(String barcode) async {
    final uri = Uri.parse(
      '$_base/$barcode.json'
      '?fields=product_name,product_name_ar,generic_name,generic_name_ar,'
      'brands,image_front_url,ingredients_text,ingredients_text_ar,'
      'allergens_tags,additives_tags,nutriscore_grade,nutriments',
    );

    http.Response res;
    try {
      res = await http
          .get(
            uri,
            // Open Food Facts' API usage policy requires a descriptive
            // User-Agent identifying the app; requests without one can be
            // throttled or rejected, which otherwise looks like "no internet".
            headers: {
              'User-Agent': 'Sufra-Android/1.0 (family food scanner app)',
            },
          )
          .timeout(const Duration(seconds: 12));
    } on Exception catch (e) {
      throw ProductLookupException(
        'تعذّر الوصول إلى الإنترنت. تحقق من اتصال هاتفك بالشبكة وحاول مجددًا.\n($e)',
      );
    }

    if (res.statusCode != 200) {
      throw ProductLookupException('تعذّر الاتصال بقاعدة بيانات المنتجات. تحقق من اتصالك بالإنترنت.');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final status = json['status'];
    if (status == 0 || json['product'] == null) {
      throw ProductLookupException('لم يتم العثور على هذا المنتج في قاعدة البيانات.');
    }

    return ScannedProduct.fromOpenFoodFacts(json, barcode);
  }
}
