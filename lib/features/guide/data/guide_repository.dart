import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class GuideContent {
  final String id;
  final String title;
  final String category; // "UMRAH", "DUA", "ZIARAH"
  final String arabicText;
  final String latinText;
  final String translation;
  final String? audioUrl;
  final int sequenceOrder;

  GuideContent({
    required this.id,
    required this.title,
    required this.category,
    required this.arabicText,
    required this.latinText,
    required this.translation,
    this.audioUrl,
    required this.sequenceOrder,
  });

  factory GuideContent.fromJson(Map<String, dynamic> json) {
    return GuideContent(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      category: json['category'] ?? 'GENERAL',
      arabicText: json['arabic_text'] ?? '',
      latinText: json['latin_text'] ?? '',
      translation: json['translation'] ?? '',
      audioUrl: json['audio_url'],
      sequenceOrder: json['sequence_order'] ?? 0,
    );
  }
}

class GuideRepository {
  final ApiClient _api;

  GuideRepository(this._api);

  Future<List<GuideContent>> getGuides(String category) async {
    try {
     final response = await _api.get('/manasik?category=$category');
      
      return (response.data as List)
          .map((e) => GuideContent.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw "Failed to load guides: ${e.message}";
    }
  }
}