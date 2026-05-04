import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:logger/logger.dart';

class TranslationService {
  final _logger = Logger();
  
  // Cache simple pour éviter les appels inutiles
  // Clé: "langueSource_langueCible_texte", Valeur: "texteTraduit"
  final Map<String, String> _cache = {};

  /// Traduit un texte vers la langue cible
  Future<String> translate(String text, String targetLanguage) async {
    if (text.isEmpty || targetLanguage == 'fra') return text; // Pas besoin de traduire le français pour l'instant (ou si vide)

    final cacheKey = "${targetLanguage}_$text";
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      _logger.i("🌍 Traduction réelle de '$text' vers $targetLanguage...");
      
      final encodedText = Uri.encodeComponent(text);
      final url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=$encodedText";
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // La réponse de cette API est un peu complexe : [[["Traduction", "Original", ...]]]
        final translatedText = data[0][0][0] as String;
        
        _logger.i("✅ Traduction réussie : $translatedText");
        _cache[cacheKey] = translatedText;
        return translatedText;
      } else {
        _logger.e("❌ Erreur API Google: ${response.statusCode}");
        return text;
      }
    } catch (e) {
      _logger.e("Erreur de traduction: $e");
      return text;
    }
  }

  /// Traduit une liste de textes en une seule fois (Batch)
  Future<Map<String, String>> translateBatch(List<String> texts, String targetLanguage) async {
    // Logique pour traduire plusieurs textes d'un coup pour optimiser les appels API
    Map<String, String> results = {};
    for (var text in texts) {
      results[text] = await translate(text, targetLanguage);
    }
    return results;
  }
}
